{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # Override to inject gamemode into FHS env so launchers detect and use it
    (heroic.override { extraPkgs = p: [ p.gamemode ]; })
    prismlauncher
    (lutris.override { extraLibraries = p: [ p.gamemode ]; })
    hydralauncher
    # "Unsupported Environment: not sandboxed" popup is purely informative: the
    # "sandbox" refers to Flatpak (upstream's official distribution), not real
    # security. Disable via override. See nixpkgs#384555.
    #
    # Known bug: external wine runners downloaded by Bottles/Lutris (soda,
    # wine-ge) are 32-bit ELF with interpreter /lib/ld-linux.so.2, which NixOS
    # lacks (nix-ld only handles 64-bit). This causes a false "DXVK requires
    # Vulkan" / "Required instance extensions not supported" error even though
    # Vulkan works system-wide. Track: nixpkgs#511314.
    #
    # Workaround: use wineWowPackages.staging from nixpkgs (patched for NixOS)
    # and configure it as the Wine runner in Lutris → Preferences → Runners →
    # Wine → custom path pointing to this wine binary.
    (bottles.override { removeWarningPopup = true; })

    # Wine with 64+32 bit support, patched for NixOS (works where wine-ge fails).
    # wineWow64Packages is the new name (wineWowPackages is deprecated) and is
    # the one that has pre-built binaries on cache.nixos.org.
    wineWow64Packages.staging
    winetricks
    vkd3d-proton # DirectX 12 → Vulkan translation (needed for UE4/5 games)

    # Bottles requires `vulkaninfo` in PATH to enable DXVK/VKD3D/NVAPI toggles.
    # See bottles/backend/utils/vulkan.py: check_support() uses
    # shutil.which("vulkaninfo") to decide whether Vulkan is functional; if the
    # binary is missing those toggles are permanently greyed out, even when
    # Vulkan itself works system-wide.
    vulkan-tools

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
