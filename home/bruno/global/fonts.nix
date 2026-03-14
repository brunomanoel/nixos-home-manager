{ pkgs, ... }:
{

  home.packages = with pkgs.nerd-fonts; [
    meslo-lg
    hack
  ];

  fonts.fontconfig.enable = true;
}
