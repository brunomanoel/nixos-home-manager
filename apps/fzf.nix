{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    tree
  ];

  programs.fd = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    fileWidgetOptions = [
      "--preview 'head {}'"
    ];
    fileWidgetCommand = "fd --type f";
    changeDirWidgetOptions = [
      "--preview 'tree -C {} | head -200'"
    ];
  };
}
