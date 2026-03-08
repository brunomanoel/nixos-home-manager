{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./zsh.nix
    ./starship.nix
    ./fzf.nix
    ./tmux.nix
    ./ssh.nix
    ../dev/neovim
  ];

  home.packages = with pkgs;
    [
      unzip
    tldr
    fastfetch
    pfetch
    ncdu
    wget

    # Nix Tools
    nixd # Nix LSP
    nixfmt-rfc-style # Nix formatter (official RFC 166 style)
    nvd # Nix version manager
    nix-diff # Differ, more detailed
    nix-output-monitor # Monitor nix builds
    nh # Nice wrapper for NixOS and Home Manager
    ]
    ++ lib.optionals stdenv.isLinux [
      wl-clipboard
    ];

  programs = {
    bash.enable = true;
    command-not-found.enable = true;
    htop.enable = true;
    btop.enable = true;
    bottom.enable = true;
    ripgrep.enable = true; # Better grep
    zoxide.enable = true; # Better cd
    navi.enable = true;
    jq.enable = true;
  };

  programs.pay-respects = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
    };
  };

  programs.micro = {
    enable = true;
    settings = {
      autosu = true;
      tabstospaces = true;
    };
  };

  # Better ls
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    icons = "always";
    colors = "always";
    git = true;
    extraOptions = [
      "--group-directories-first"
    ];
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()

      config.font = wezterm.font('FiraCode Nerd Font')
      config.font_size = 16.0
      config.window_background_opacity = 0.8
      config.color_scheme = 'Catppuccin Mocha'

      return config
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
    silent = true;
    config.global = {
      hide_env_diff = true;
    };
  };
}
