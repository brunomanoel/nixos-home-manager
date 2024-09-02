{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    gnome-tweaks
    # gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.vitals
    # gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.space-bar
    gnomeExtensions.gsconnect
    gnomeExtensions.appindicator
    gnomeExtensions.gtile
    gnomeExtensions.nothing-to-say
    gnomeExtensions.fullscreen-avoider
    gnomeExtensions.tophat
    gnomeExtensions.just-perfection
    gnomeExtensions.blur-my-shell
    gnomeExtensions.dash-to-dock
    gnomeExtensions.dash-to-panel
    gnomeExtensions.wireless-hid
    gnomeExtensions.no-overview
  ];
}
