{
  pkgs ? import <nixpkgs> { },
  ...
}:
{
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes ca-derivations";
    shellHook = ''
      export NH_FLAKE="$HOME/dotfiles"
    '';
    nativeBuildInputs = with pkgs; [
      fastfetch
      pfetch
      micro
      nix
      home-manager
      git
      nvd
      nix-output-monitor
      nh # Nice wrapper for NixOS and Home Manager
      nodejs_22
      keepassxc
      sops
      age
      ssh-to-age
    ];
  };
}
