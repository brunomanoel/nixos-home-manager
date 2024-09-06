{ config, pkgs, lib, ... }:
{
  imports = [
    ./zsh.nix
    ./starship.nix
    ./fzf.nix
    ./tmux.nix
  ];

  home.packages = with pkgs; [
    wl-clipboard
    unzip
    tldr
    fastfetch
    pfetch
    cowsay

    # Nix Tools
    nvd # Nix version manager
    nix-output-monitor # Monitor nix builds
    nh # Nice wrapper for NixOS and Home Manager
  ];

  programs = {
    htop.enable = true;
    command-not-found.enable = true;
    btop.enable = true;
    bat.enable = true;
    ripgrep.enable = true;
    bash.enable = true;
  };

  programs.ssh = {
    enable = true;
  };

  programs.micro = {
    enable = true;
    settings = {
      autosu = true;
      tabstospaces = true;
    };
  };

  programs.thefuck = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  # Better cd
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  # Better ls
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    icons = true;
    extraOptions = [
      "--color=always"
      "--icons=always"
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
}
