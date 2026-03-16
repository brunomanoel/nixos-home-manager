{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Linux: keychain starts the SSH agent and pre-loads keys at login.
  # macOS: UseKeychain in the matchBlock delegates to the system Keychain.
  programs.keychain = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    keys = [ "github.key" ];
    extraFlags = [ "--quiet" ];
  };

  # GPG — required for YubiKey OpenPGP operations and future gpg-agent SSH migration
  programs.gpg.enable = true;

  services.gpg-agent = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    enableScDaemon = true;
    enableExtraSocket = true;
    pinentry.package = if pkgs.stdenv.isLinux then pkgs.pinentry-gnome3 else pkgs.pinentry-curses;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      forwardAgent = true;
      addKeysToAgent = "yes";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = true;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "auto";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "10m";
      extraOptions = lib.mkIf pkgs.stdenv.isDarwin {
        UseKeychain = "yes";
      };
    };
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        identityFile = "~/.ssh/github.key";
      };
      "cloudarm" = {
        hostname = "10.100.0.1";
        user = "bruno";
        identityFile = "~/.ssh/cloudarm.key";
      };
    };
  };
}
