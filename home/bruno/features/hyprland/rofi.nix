{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    font = "FiraCode Nerd Font 14";
    extraConfig = {
      show-icons = true;
      icon-theme = "Adwaita";
      display-drun = " ";
      display-run = " ";
      display-window = " ";
      drun-display-format = "{name}";
    };
    theme = let
      inherit (builtins) toString;
      mkLiteral = value: { _type = "literal"; inherit value; };
    in {
      "*" = {
        bg0 = mkLiteral "#1e1e2eff";
        bg1 = mkLiteral "#313244ff";
        fg0 = mkLiteral "#cdd6f4ff";
        fg1 = mkLiteral "#a6adc8ff";
        accent = mkLiteral "#cba6f7ff";

        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg0";
        margin = 0;
        padding = 0;
        spacing = 0;
      };

      window = {
        width = mkLiteral "600px";
        background-color = mkLiteral "@bg0";
        border = mkLiteral "2px solid";
        border-color = mkLiteral "@accent";
        border-radius = mkLiteral "12px";
      };

      inputbar = {
        padding = mkLiteral "12px";
        spacing = mkLiteral "12px";
        children = map mkLiteral [ "icon-search" "entry" ];
        background-color = mkLiteral "@bg1";
      };

      "icon-search" = {
        expand = false;
        filename = "edit-find";
        size = mkLiteral "24px";
        vertical-align = mkLiteral "0.5";
      };

      entry = {
        placeholder = "Search...";
        placeholder-color = mkLiteral "@fg1";
      };

      listview = {
        lines = 8;
        fixed-height = true;
        padding = mkLiteral "4px 0";
      };

      element = {
        padding = mkLiteral "8px 12px";
        spacing = mkLiteral "12px";
      };

      "element selected" = {
        background-color = mkLiteral "@bg1";
        text-color = mkLiteral "@accent";
      };

      element-icon = {
        size = mkLiteral "24px";
        vertical-align = mkLiteral "0.5";
      };

      element-text = {
        vertical-align = mkLiteral "0.5";
      };
    };
  };
}
