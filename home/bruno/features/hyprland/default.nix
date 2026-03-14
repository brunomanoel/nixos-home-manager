{ pkgs, ... }:
let
  hypr-keybinds = pkgs.writeShellScriptBin "hypr-keybinds" ''
    hyprctl binds -j | ${pkgs.jq}/bin/jq -r '.[] | "\(.modmask | tostring | gsub("64";"Super") | gsub("1";"Shift") | gsub("0";"")) + \(.key) → \(.dispatcher) \(.arg)"' | \
      ${pkgs.rofi-wayland}/bin/rofi -dmenu -i -p "Keybinds" -theme-str 'window { width: 800px; }'
  '';
in
{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./rofi.nix
    ./mako.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./hyprpaper.nix
  ];

  home.packages = with pkgs; [
    hypr-keybinds # Super+/ shows keybind cheatsheet
    grimblast # screenshot tool for Hyprland
    cliphist # clipboard history
    wl-clipboard # wl-copy / wl-paste
    brightnessctl # backlight control
    playerctl # media key control
    networkmanagerapplet # systray network
    blueman # systray bluetooth
    pavucontrol # volume mixer
    nautilus # file manager
  ];
}
