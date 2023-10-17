{ config, lib, pkgs, modulesPath, ... }:

{
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = (with pkgs; [
      gnome-photos
      gnome-tour
    ]) ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gnome-terminal
      gedit # text editor
      epiphany # web browser
      geary # email reader
      evince # document viewer
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      gnome-maps
      gnome-contacts
      gnome-weather
    ]);
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  programs.dconf.enable = true; # https://nixos.wiki/wiki/GNOME

  programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;

  # needed for store VS Code auth token
  services.gnome.gnome-keyring.enable = true;

  services.gnome.gnome-browser-connector.enable = true;
}
