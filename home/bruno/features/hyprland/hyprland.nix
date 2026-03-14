{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null; # use system package from programs.hyprland
    xwayland.enable = true;
    systemd.enable = true;

    settings = {
      # ── Monitors ──────────────────────────────────────────────
      monitor = [
        "eDP-1, 1920x1080@120, 0x0, 1.5"
        "desc:LG Electronics, 3440x1440@85, 1280x0, 1.67"
        ", preferred, auto, 1" # fallback for any other monitor
      ];

      # ── NVIDIA env vars ──────────────────────────────────────
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        "NVD_BACKEND,direct"
        "NIXOS_OZONE_WL,1"
        "XDG_SESSION_TYPE,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
      ];

      # ── Catppuccin Mocha colors ─────────────────────────────
      "$rosewater" = "rgb(f5e0dc)";
      "$flamingo" = "rgb(f2cdcd)";
      "$pink" = "rgb(f5c2e7)";
      "$mauve" = "rgb(cba6f7)";
      "$red" = "rgb(f38ba8)";
      "$maroon" = "rgb(eba0ac)";
      "$peach" = "rgb(fab387)";
      "$yellow" = "rgb(f9e2af)";
      "$green" = "rgb(a6e3a1)";
      "$teal" = "rgb(94e2d5)";
      "$sky" = "rgb(89dceb)";
      "$sapphire" = "rgb(74c7ec)";
      "$blue" = "rgb(89b4fa)";
      "$lavender" = "rgb(b4befe)";
      "$text" = "rgb(cdd6f4)";
      "$subtext1" = "rgb(bac2de)";
      "$subtext0" = "rgb(a6adc8)";
      "$overlay2" = "rgb(9399b2)";
      "$overlay1" = "rgb(7f849c)";
      "$overlay0" = "rgb(6c7086)";
      "$surface2" = "rgb(585b70)";
      "$surface1" = "rgb(45475a)";
      "$surface0" = "rgb(313244)";
      "$base" = "rgb(1e1e2e)";
      "$mantle" = "rgb(181825)";
      "$crust" = "rgb(11111b)";

      # ── General ──────────────────────────────────────────────
      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "$mauve $blue 45deg";
        "col.inactive_border" = "$surface0";
        layout = "dwindle";
      };

      # ── Decoration ──────────────────────────────────────────
      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 6;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
        };
        shadow = {
          enabled = true;
          range = 12;
          render_power = 3;
          color = "$crust";
        };
      };

      # ── Animations ──────────────────────────────────────────
      animations = {
        enabled = true;
        bezier = [
          "ease, 0.25, 0.1, 0.25, 1"
          "easeOut, 0, 0, 0.58, 1"
          "easeInOut, 0.42, 0, 0.58, 1"
        ];
        animation = [
          "windows, 1, 4, ease, slide"
          "windowsOut, 1, 4, easeOut, slide"
          "fade, 1, 4, ease"
          "workspaces, 1, 4, easeInOut, slide"
          "border, 1, 10, ease"
        ];
      };

      # ── Input ───────────────────────────────────────────────
      input = {
        kb_layout = "br";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
        };
      };

      # ── Layouts ─────────────────────────────────────────────
      dwindle = {
        pseudotile = true;
        preserve_split = true;
        force_split = 2; # always split to the right/bottom
      };

      # ── Misc ────────────────────────────────────────────────
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      # ── Window rules ────────────────────────────────────────
      windowrulev2 = [
        "float, class:^(pavucontrol)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(nm-connection-editor)$"
        "float, class:^(.blueman-manager-wrapped)$"
        "float, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"
      ];

      # ── Keybinds (AwesomeWM style) ─────────────────────────
      "$mod" = "SUPER";

      bind = [
        # ── Apps ──
        "$mod, Return, exec, wezterm"
        "$mod, D, exec, rofi -show drun -show-icons"
        "$mod, Q, killactive"
        "$mod SHIFT, Q, exit"
        "$mod, E, exec, nautilus"
        "$mod, L, exec, hyprlock"

        # ── Window management ──
        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        # $mod+L is lock — use $mod+semicolon for right
        "$mod, semicolon, movefocus, r"

        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, semicolon, movewindow, r"

        "$mod, F, fullscreen, 0"
        "$mod, Space, togglefloating"
        "$mod, P, pseudo" # dwindle pseudotile

        # ── Workspaces ──
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"

        # ── Mouse workspace scroll ──
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # ── Screenshot ──
        ", Print, exec, grimblast copy area"
        "SHIFT, Print, exec, grimblast copy screen"

        # ── Clipboard ──
        "$mod, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"

        # ── Help ──
        "$mod, slash, exec, hypr-keybinds"

        # ── Submaps ──
        "$mod, S, submap, resize"
      ];

      # ── Mouse binds ──
      bindm = [
        "$mod, mouse:272, movewindow" # Super + LMB drag
        "$mod, mouse:273, resizewindow" # Super + RMB drag
      ];

      # ── Media / hardware keys ──
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # ── Autostart ──
      exec-once = [
        "waybar"
        "hyprpaper"
        "mako"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "nm-applet --indicator"
        "blueman-applet"
      ];
    };

    # ── Submaps (experimental keybinds) ──────────────────────
    # Enter submap: $mod+S, then use keys inside, Escape to exit
    submaps = {
      resize = {
        onDispatch = "reset";
        settings = {
          bind = [
            ", H, resizeactive, -40 0"
            ", J, resizeactive, 0 40"
            ", K, resizeactive, 0 -40"
            ", L, resizeactive, 40 0"
            ", escape, submap, reset"
          ];
        };
      };
    };
  };

}
