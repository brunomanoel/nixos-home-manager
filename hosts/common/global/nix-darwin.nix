# Nix settings for macOS — mirrors nix.nix but without Linux-only options
# (auto-optimise-store and optimise.automatic are not supported on Darwin;
#  gc.dates uses systemd format; gc.interval is used instead)
{
  inputs,
  lib,
  pkgs,
  ...
}: let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in {
  nix = {
    settings = {
      trusted-users = [
        "root"
        "@admin"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
    };

    gc = {
      automatic = true;
      interval = {
        Hour = 3;
        Minute = 15;
        Weekday = 0; # Sunday
      };
      options = "--delete-older-than +3";
    };

    # Add each flake input as a registry and nix_path
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };
}
