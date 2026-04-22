{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # Override to inject gamemode into FHS env so launchers detect and use it
    (heroic.override { extraPkgs = p: [ p.gamemode ]; })
    prismlauncher
    (lutris.override { extraLibraries = p: [ p.gamemode ]; })
    hydralauncher

    # Gamepad tooling
    jstest-gtk # GUI tester (axes, buttons, calibration)
    sdl-jstest # SDL2-based CLI tester, matches what games actually see
    gamepad-tool # edit/generate SDL2 controller mappings
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
