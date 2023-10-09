{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    neofetch
  	cowsay
  	variety
    discord
	thefuck
	obsidian

  ];

  programs.chromium = {
	enable = true;
  };
  
  programs.firefox = {
	enable = true;
	package = pkgs.firefox.override {
	  cfg = {
		enableGnomeExtensions = true;
	  };
	};
  };

  programs.micro = {
  	enable = true;
  	settings = {
  	  autosu = true;
  	  tabstospaces = true;
  	};
  };

  programs.obs-studio.enable = true;
}
