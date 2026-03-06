{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../common/global/darwin.nix
    ../common/users/bruno/darwin.nix
  ];

  networking.hostName = "mac";

  system.stateVersion = 5;
}
