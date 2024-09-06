{ pkgs, ... }: {
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Meslo" "Hack" ]; })
  ];

  fonts.fontconfig.enable = true;
}
