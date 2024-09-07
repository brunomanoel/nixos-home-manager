{ config, pkgs, ... }:
{
  # programs.steam = {
    # enable = true;
    # remotePlay.openFirewall = true;
    # dedicatedServer.openFirewall = true;
  # };

  home.packages = with pkgs; [
    steam
    heroic
    prismlauncher
    lutris
    gamescope
    gamemode
    protontricks
    wineWowPackages.waylandFull
    # wine-wayland
    # wine
  ];

  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
  };
}
