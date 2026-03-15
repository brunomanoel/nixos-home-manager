# Desktop-only system config — not imported by servers
{ ... }:
{
  imports = [
    ./font.nix
    ./cuda.nix
  ];

  hardware.enableRedistributableFirmware = true;

  # Keyboard layout — only relevant for graphical sessions
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };
}
