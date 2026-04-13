{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./global
    ./global/fonts.nix

    ./features/cli
    ./features/cli/wezterm.nix
    ./features/git.nix
    ./features/keepassxc.nix
  ];
}
