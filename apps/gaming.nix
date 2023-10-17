{ config, pkgs, ... }:
{
  # programs.steam = {
    # enable = true;
    # remotePlay.openFirewall = true;
    # dedicatedServer.openFirewall = true;   
  # };

  home.packages = with pkgs; [
    steam
    wineWowPackages.waylandFull
    # wine-wayland
    # wine
    heroic
  ];

  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
  };
}
