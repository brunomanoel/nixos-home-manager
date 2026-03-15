# This file (and the global directory) holds config that i use on all hosts
{
  inputs,
  outputs,
  ...
}:
{
  imports = [
    ./locale.nix
    ./zsh.nix
    ./nix.nix
  ];

  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };

  nixpkgs = {
    overlays = [ ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
}
