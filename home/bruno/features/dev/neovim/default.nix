{ config, pkgs, ... }:
{
  imports = [
    ./debug.nix
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      vim-nix
      nvim-treesitter.withAllGrammars
      nvim-tree-lua

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
      # LSP
      nvim-lspconfig

      # Themes
      dracula-nvim
      catppuccin-nvim
    ];
  extraConfig = ''
    "Enable relative line numbers
    set number relativenumber

    "Scroll up and down
    nmap <C-j> <C-e>
    nmap <C-k> <C-y>
  '';
  };
}
