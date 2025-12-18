{ config, pkgs, lib, ... }:
{
  imports = [
    ./zsh.nix
    ./starship.nix
    ./fzf.nix
    ./tmux.nix
    ./ssh.nix
    ./gpg.nix
    ../dev/neovim
  ];

  home.packages = with pkgs; [
    wl-clipboard
    unzip
    tldr
    fastfetch
    pfetch
    ncdu

    # Nix Tools
    comma # Runs software withouth installing it
    nixd # Nix LSP
    alejandra # Nix formatter
    nixfmt-rfc-style
    nvd # Nix version manager
    nix-diff # Differ, more detailed
    nix-output-monitor # Monitor nix builds
    nh # Nice wrapper for NixOS and Home Manager
  ];

  programs = {
    bash.enable = true;
    command-not-found.enable = true;
    htop.enable = true;
    btop.enable = true;
    bottom.enable = true;
    ripgrep.enable = true; # Better grep
    zoxide.enable = true; # Better cd
    dircolors.enable = true;
    navi.enable = true;
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

  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 0.8;
      font.size = 16.0;
      font.normal.family = "FiraCode Nerd Font";
    };
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
