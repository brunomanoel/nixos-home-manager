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
      # macOS Keychain: persists keys across reboots without manual ssh-add
      extraOptions = lib.mkIf pkgs.stdenv.isDarwin {
        UseKeychain = "yes";
      };
    };
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        identityFile = "~/.ssh/github.key";
      };
    };
  };
}
