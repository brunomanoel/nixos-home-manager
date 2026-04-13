# Daily backup of KeePassXC databases to Google Drive via Rclone.
# The "gdrive" remote must be configured manually once: `rclone config`
# The OAuth2 token is saved to ~/.config/rclone/rclone.conf automatically.
{ pkgs, lib, ... }:
{
  programs.rclone.enable = true;

  # Daily backup timer
  systemd.user.services.keepassxc-backup = {
    Unit = {
      Description = "Backup KeePassXC databases to Google Drive";
    };
    Service = {
      Type = "oneshot";
      ExecStart = toString (
        pkgs.writeShellScript "keepassxc-backup" ''
          ${pkgs.rclone}/bin/rclone copy ~/KeePassXC gdrive:KeePassXC \
            --include "*.kdbx" \
            --log-level INFO
        ''
      );
    };
  };

  systemd.user.timers.keepassxc-backup = {
    Unit = {
      Description = "Daily backup of KeePassXC databases to Google Drive";
    };
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
