{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    fastfetch
    cowsay
    variety
    discord
    obsidian
    spotify
    libgtop
    noisetorch
  ];

  programs.chromium = {
    enable = true;
  };

  programs.firefox = {
    enable = true;
      # package = pkgs.firefox-wayland.override {
    package = pkgs.firefox.override {
      cfg = {
        nativeMessagingHosts.gsconnect = true;
        enableGnomeExtensions = true;
      };
    };
  };

  programs.micro = {
  	enable = true;
  	settings = {
  	  autosu = true;
  	  tabstospaces = true;
  	};
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-vkcapture
      obs-source-clone
      obs-pipewire-audio-capture
      obs-move-transition
      obs-backgroundremoval
      obs-3d-effect
      looking-glass-obs
      input-overlay
      advanced-scene-switcher
      obs-shaderfilter
    ];
  };

  services.easyeffects.enable = true;
}
