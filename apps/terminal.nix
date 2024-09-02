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
  ];

  programs = {
    htop.enable = true;
    command-not-found.enable = true;
    btop.enable = true;
    bat.enable = true;
    ripgrep.enable = true;
  };

  programs.ssh = {
    enable = true;
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

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 0.8;
      font.size = 16.0;
      # font.normal.family = 'Fira Code';
    };
  };
}
