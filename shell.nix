{ pkgs ? import <nixpkgs> {}, ... }: {
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes ca-derivations";
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      git
      nvd
      nix-output-monitor
      nh # Nice wrapper for NixOS and Home Manager
    ];
  };
}
