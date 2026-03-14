# Headless server — minimal home-manager config
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

    ./features/git.nix
  ];
}
