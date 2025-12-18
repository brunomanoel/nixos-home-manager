{
  pkgs,
  config,
  lib,
  ...
}:
{
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = if config.gtk.enable then pkgs.pinentry-gtk2 else pkgs.pinentry-tty;
  };

  home.packages = lib.optional config.gtk.enable pkgs.gcr;

  programs =
    let
      fixGpg = /* bash */ ''
        gpgconf --launch gpg-agent
      '';
    in
    {
      # Start gpg-agent if it's not running or tunneled in
      # SSH does not start it automatically, so this is needed to avoid having to use a gpg command at startup
      # https://www.gnupg.org/faq/whats-new-in-2.1.html#autostart
      bash.profileExtra = fixGpg;
      zsh.loginExtra = fixGpg;

      gpg = {
        enable = true;
        settings = {
          # trust-model = "tofu+pgp";
        };
      };
    };
}
