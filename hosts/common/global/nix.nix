{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in
{
  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
      max-jobs = 4;
      cores = 3;
      #   warn-dirty = false;
      #   flake-registry = ""; # Disable global flake registry
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Add each flake input as a registry and nix_path
    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    # Making legacy nix commands consistent as well, awesome!
    # nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };
}
