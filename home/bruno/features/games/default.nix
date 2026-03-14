{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    heroic
    prismlauncher
    lutris
  ];

  programs.mangohud = {
    enable = true;
    enableSessionWide = false;
    settings = {
      toggle_hud = "Shift_R+F12";
      position = "top-left";
      font_size = 20;
      gpu_stats = true;
      gpu_temp = true;
      gpu_power = true;
      cpu_stats = true;
      cpu_temp = true;
      ram = true;
      vram = true;
      frame_timing = true;
    };
  };
}
