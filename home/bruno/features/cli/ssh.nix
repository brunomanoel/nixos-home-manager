{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.file.".ssh/github.pub".text =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGkT6NTxjPkWX9V+jCqous6T7bmC/5E/XG5cxttP8yJO 26349861+brunomanoel@users.noreply.github.com\n";
  home.file.".ssh/cloudarm.pub".text =
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDqEFTEOwUFIpboG2ZNlvLSvVJtnKVGicbJY84+63UArxwPd6t4ErcLp/m6NUN+pANLEcFBEM8veDkGvKGPqUAJZvLX0wdkRo8mvj/8OZ6AbCQmUQ62lYiBUpPa1xGdvEiGyCVNHp+IyFDjm9VvOTUMaOp+Afw3fCx9DwV3+r0CnEn7Scdfhc6iQak0xfLPbXyHRbcQ3762z57hW1qWsYWApNKb6qGy38jzBznfwZu6UIfmsQ9AOsvSTeXysIGKqR5/gck03fpR0CwVpoXRgCQG2b019bK4DDDEvvmnCYjf8z4iq4WXTk66AM/p5oQKR1uspV93cUshHsuaenrO+ySJ\n";

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
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
        identityFile = "~/.ssh/github.pub";
      };
      "cloudarm" = {
        hostname = "10.100.0.1";
        user = "bruno";
        identityFile = "~/.ssh/cloudarm.pub";
      };
    };
  };
}
