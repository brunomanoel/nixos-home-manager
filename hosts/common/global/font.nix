{ pkgs, ... }: {
    fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
    ];
    fontDir.enable = true;
  };
}
