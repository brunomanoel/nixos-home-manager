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

      # Treesitter: curated grammars + textobjects queries
      (nvim-treesitter.withPlugins (
        p: with p; [
          # Main languages
          typescript
          tsx
          javascript
          jsdoc
          go
          gomod
          gosum
          gowork
          python
          lua
          luadoc
          luap
          nix
          php
          java
          javadoc
          c_sharp

          # Ubiquitous formats
          json
          yaml
          toml
          markdown
          markdown_inline
          html
          xml
          css
          bash
          zsh
          dockerfile
          nginx
          latex
          csv

          # Git / diff
          gitignore
          gitcommit
          gitattributes
          git_rebase
          diff

          # Utilities
          regex
          sql
          vim
          query
        ]
      ))
      nvim-treesitter-textobjects

      nvim-tree-lua

      # Telescope
      telescope-nvim
      plenary-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      nvim-web-devicons

      lualine-nvim
      which-key-nvim

      # mini.nvim — modular suite (ai, pairs, surround, bracketed, indentscope, splitjoin)
      mini-nvim

      # Notifications
      nvim-notify

      # Git
      gitsigns-nvim
      lazygit-nvim

      # Code navigation / hints
      todo-comments-nvim

      # Themes
      dracula-nvim
      catppuccin-nvim
    ];
    initLua = builtins.readFile ./init.lua;
  };

  xdg.configFile."nvim/lua" = {
    source = ./lua;
    recursive = true;
  };
}
