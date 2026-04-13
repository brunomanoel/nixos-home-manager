# Headless server — minimal home-manager config
# Does NOT import ./global (which pulls claude.nix requiring HM unstable)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./features/git.nix
    ./features/cli/ssh.nix
  ];

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    username = lib.mkDefault "bruno";
    homeDirectory = "/home/bruno";
    stateVersion = "23.05";
  };
}
