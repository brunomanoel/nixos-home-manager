{ config, pkgs, ... }:
{
  imports = [
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
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
      # {
      #   plugin = ;
      #   config = ''
      #   '';
      # }
      lualine-nvim
      which-key-nvim
      vim-tmux-navigator

      # Themes
      dracula-nvim
      catppuccin-nvim
    ];
  extraLuaConfig = builtins.readFile(./init.lua);
  };
}
