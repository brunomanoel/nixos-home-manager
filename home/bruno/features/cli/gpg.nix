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
    # Cache SSH keys for 24h so passphrase is only asked once per boot
    defaultCacheTtlSsh = 86400;
    maxCacheTtlSsh = 86400;
  };

  home.packages = lib.optional config.gtk.enable pkgs.gcr;

  programs =
    let
      fixGpg = /* bash */ ''
        gpgconf --launch gpg-agent
        ssh-add ~/.ssh/github.key 2>/dev/null
      '';
    in
    {
      # Start gpg-agent (as SSH agent) and pre-load the SSH key.
      # Passphrase is asked once via pinentry; cached for 24h (see defaultCacheTtlSsh).
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
