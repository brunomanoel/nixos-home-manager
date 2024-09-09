{ config, pkgs, lib, ... }:
{
  imports = [
    ./zsh.nix
    ./starship.nix
    ./fzf.nix
    ./tmux.nix
    ../dev/neovim
  ];

  home.packages = with pkgs; [
    wl-clipboard
    unzip
    tldr
    fastfetch
    pfetch

    # Nix Tools
    comma # Runs software withouth installing it
    nvd # Nix version manager
    nix-output-monitor # Monitor nix builds
    nh # Nice wrapper for NixOS and Home Manager
  ];

  programs = {
    bash.enable = true;
    command-not-found.enable = true;
    htop.enable = true;
    btop.enable = true;
    ripgrep.enable = true; # Better grep
    zoxide.enable = true; # Better cd
    thefuck.enable = true;
    dircolors.enable = true;
    navi.enable = true;
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
    };
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

  # Better ls
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    icons = true;
    extraOptions = [
      "--group-directories-first"
      "--color=always"
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
