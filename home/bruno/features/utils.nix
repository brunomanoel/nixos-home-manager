{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    variety
    discord
    obsidian
    spotify
    libgtop
    qalculate-gtk
    krita # painting app
    stremio-linux-shell
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

  programs.vesktop = {
    enable = true;
    vencord.settings = {
      autoUpdate = true;
      autoUpdateNotification = true;
      notifyAboutUpdates = true;
      plugins = {
        ClearURLs.enabled = true;
        FixYoutubeEmbeds.enabled = true;
      };
    };
  };
}
