# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    ./global

  	./features/git.nix
  	./features/dev-essentials.nix
  ];

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    # pinentryPackage = pkgs.pinentry-tty;
  };

  home.packages = with pkgs; [
    pinentry-tty
  ];

}
