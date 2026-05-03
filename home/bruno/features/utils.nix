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
    peazip # archive manager GUI (testing for multi-part RAR)
  ];

  programs.chromium = {
    enable = true;
    # IntranetRedirectBehavior=3 forces single-word omnibox inputs to resolve
    # via DNS instead of being sent to the search engine — required for *.lab.
    extraOpts = {
      IntranetRedirectBehavior = 3;
    };
  };

  programs.firefox = {
    enable = true;
    # Treat single-word inputs as hostnames first, then fall back to search.
    # Required for *.lab to resolve via DNS instead of triggering search.
    profiles.default = {
      id = 0;
      isDefault = true;
      settings = {
        "browser.fixup.dns_first_for_single_words" = true;
      };
    };
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
