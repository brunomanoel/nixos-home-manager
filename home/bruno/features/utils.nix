{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    variety
    discord
    obsidian
    spotify
    libgtop
    noisetorch
    qalculate-gtk
  ];

  programs.chromium = {
    enable = true;
  };

  programs.firefox = {
    enable = true;
      # package = pkgs.firefox-wayland.override {
    # package = pkgs.firefox.override {
    #   cfg = {
    #     # nativeMessagingHosts.gsconnect = true;
    #     enableGnomeExtensions = true;
    #   };
    # };
  };

  services.easyeffects.enable = true;
}
