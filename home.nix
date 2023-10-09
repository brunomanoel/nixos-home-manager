{ config, pkgs, ... }:
{
  imports = [
  	./apps/terminal.nix
  	./apps/git.nix
  	./apps/utils.nix
  	./apps/dev-essentials.nix
    # ./apps/gaming.nix
  ];

  home.username = "bruno";
  home.homeDirectory = "/home/bruno";
  home.stateVersion = "23.05";
  # home.stateVersion = "unstable";
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.gpg.enable = true;
  services.gpg-agent = {                          
    enable = true;
    enableSshSupport = true;
  };
}
