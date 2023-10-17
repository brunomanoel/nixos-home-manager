{ config, pkgs, ... }:
{
  programs.vscode = {
	enable = true;
	package = pkgs.vscode.fhs;
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
