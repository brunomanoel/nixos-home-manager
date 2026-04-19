{ config, pkgs, ... }:
{
  imports = [
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;
    plugins = with pkgs.vimPlugins; [
      vim-nix
      nvim-treesitter.withAllGrammars
      nvim-tree-lua

      # Telescope
      telescope-nvim
      plenary-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      nvim-web-devicons

      lualine-nvim
      which-key-nvim

      # Themes
      dracula-nvim
      catppuccin-nvim
    ];
    extraLuaConfig = builtins.readFile ./init.lua;
  };

  xdg.configFile."nvim/lua" = {
    source = ./lua;
    recursive = true;
  };
}
