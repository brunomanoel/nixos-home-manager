# Desktop-only system config — not imported by servers
{ ... }:
{
  imports = [
    ./font.nix
    ./cuda.nix
  ];

  hardware.enableRedistributableFirmware = true;

  # OpenSSH agent started at login — KeePassXC injects keys into this agent.
  # https://keepassxc.org/docs — SSH Agent integration does not provide an agent itself.
  programs.ssh.startAgent = true;

  # Chromium enterprise policy: resolve single-word omnibox inputs via DNS
  # instead of sending to search engine — required for *.lab hostnames.
  programs.chromium.extraOpts.IntranetRedirectBehavior = 3;

  # Keyboard layout — only relevant for graphical sessions
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };
}
