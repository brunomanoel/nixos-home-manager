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
    ./global/fonts.nix

    ./features/cli
    ./features/cli/wezterm.nix
    ./features/git.nix
    ./features/keepassxc.nix
    ./features/syncthing.nix
    ./features/rclone-backup.nix
    ./features/utils.nix
    ./features/dev
    ./features/games
    ./features/gnome.nix
    # ./features/hyprland
    ./features/obs-studio.nix
    ./features/video-edit.nix
  ];

  home.packages = with pkgs; [
    unityhub
  ];
}
