{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    kdePackages.kdenlive
    davinci-resolve
  ];
}
