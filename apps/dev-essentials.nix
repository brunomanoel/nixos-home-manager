{ config, pkgs, ... }:
{
  programs.vscode = {
	enable = true;
	package = pkgs.vscode.fhs;
	mutableExtensionsDir = false;
  };

  programs.neovim = {
  	enable = true;
  	viAlias = true;
  	vimAlias = true;
  	plugins = with pkgs.vimPlugins; [
  	  nvchad
  	  vim-nix
  	];
  };
}
