{ pkgs, ... }: {

  home.packages = with pkgs.nerd-fonts; [
    fira-code
    jetbrains-mono
    meslo-lg
    hack
  ];

  fonts.fontconfig.enable = true;
}
