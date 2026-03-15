# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  # You can import other home-manager modules here
  imports = [
    ./global

    ./features/cli
    ./features/git.nix

    ./features/dev/neovim
    ./features/dev/reverse-engineer.nix
  ];

}
