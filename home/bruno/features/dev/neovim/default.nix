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

      # Unified split/pane navigation (nvim + wezterm)
      smart-splits-nvim

      # Autocompletion
      blink-cmp

      # Formatter
      conform-nvim

      # Inline diagnostics (Error Lens-like)
      tiny-inline-diagnostic-nvim

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

    extraPackages = with pkgs; [
      # LSP servers
      vtsls
      gopls
      basedpyright
      lua-language-server
      nixd
      bash-language-server
      marksman
      docker-language-server
      emmet-language-server
      vscode-langservers-extracted
      biome

      # Formatters (used by conform.nvim)
      prettierd
      stylua
      gofumpt
      ruff
      nixfmt
      shfmt
    ];
  };

  xdg.configFile."nvim/lua" = {
    source = ./lua;
    recursive = true;
  };
}
