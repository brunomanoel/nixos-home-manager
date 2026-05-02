# Claude session keepalive — keeps the 5h Claude Max subscription window
# "warm" by firing a minimal message at fixed times of day.
#
# Strategy: 4 spaced windows aligned to working hours, with an intentional
# nighttime gap (~02:00-06:00 with no active window) to avoid wasting quota
# while sleeping.
#
#   06:00 → window active until 11:00
#   11:01 → window active until 16:01
#   16:02 → window active until 21:02
#   21:03 → window active until 02:03
#
# Uses an isolated HOME (/var/lib/claude-keepalive/home) with its own OAuth
# credentials so it does NOT share state with claude-proxy. This avoids
# either service stepping on the other's `.credentials.json` during token
# refresh. First-time setup: log in once interactively in this HOME (see
# README in the file footer).
#
# `claude -p` is the non-interactive (print) mode, ideal for cron-like
# execution.
{ config, pkgs, ... }:
let
  homeDir = "/var/lib/claude-keepalive/home";
  schedule = [
    "*-*-* 06:00:00"
    "*-*-* 11:01:00"
    "*-*-* 16:02:00"
    "*-*-* 21:03:00"
  ];
in
{
  # Persistent state for this keepalive's own Claude CLI HOME.
  systemd.tmpfiles.rules = [
    "d /var/lib/claude-keepalive 0700 root root -"
    "d ${homeDir} 0700 root root -"
  ];

  systemd.services.claude-keepalive = {
    description = "Claude Max session keepalive ping";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.claude-code-bin ];
    environment = {
      HOME = homeDir;
    };
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/var/lib/claude-keepalive";
      # `hi` is the smallest useful message. --output-format json makes it
      # easy to parse auth/quota failures from logs (`journalctl -u
      # claude-keepalive`). Short timeout: if claude hangs, don't burn the
      # whole window.
      TimeoutStartSec = "120s";
      ExecStart = "${pkgs.claude-code-bin}/bin/claude -p 'hi' --output-format json";
      # Don't restart on failure — the next timer will fire at the scheduled
      # time anyway.
      Restart = "no";
    };
  };

  systemd.timers.claude-keepalive = {
    description = "Claude Max session keepalive timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = schedule;
      # If the server was down at the scheduled time, fire as soon as it's
      # back up.
      Persistent = true;
      # Machine timezone applies (Oracle Cloud defaults to UTC — override
      # via time.timeZone in default.nix if needed; this host uses
      # America/Sao_Paulo via hosts/common/global/locale.nix).
      Unit = "claude-keepalive.service";
    };
  };

  # First-time setup (run once after `nixos-rebuild switch`):
  #
  #   sudo HOME=/var/lib/claude-keepalive/home \
  #     /run/current-system/sw/bin/claude
  #   # inside the REPL:
  #   /login        # follow the OAuth URL
  #   /exit
  #   sudo systemctl start claude-keepalive.service
  #   journalctl -u claude-keepalive -n 20 --no-pager
}
