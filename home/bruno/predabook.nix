# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    ./global

    ./features/git.nix
    ./features/utils.nix
    ./features/dev
    ./features/games
    ./features/gnome.nix
    ./features/obs-studio.nix
    ./features/video-edit.nix
  ];
}
