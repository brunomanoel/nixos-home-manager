{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./global

    ./features/git.nix
  ];
}
