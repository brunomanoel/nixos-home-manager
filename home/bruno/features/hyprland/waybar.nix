{ pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    systemd.target = "hyprland-session.target";

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 4;

        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [
          "tray"
          "cpu"
          "memory"
          "backlight"
          "pulseaudio"
          "network"
          "bluetooth"
          "battery"
        ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
          };
          persistent-workspaces = {
            "*" = 5;
          };
        };

        "hyprland/window" = {
          max-length = 50;
          separate-outputs = true;
        };

        clock = {
          format = "  {:%H:%M}";
          format-alt = "  {:%A, %d %B %Y  %H:%M}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };

        cpu = {
          format = "  {usage}%";
          interval = 2;
          tooltip = true;
        };

        memory = {
          format = "  {percentage}%";
          format-alt = "  {used:0.1f}G / {total:0.1f}G";
          interval = 2;
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}  {capacity}%";
          format-charging = "󰂄  {capacity}%";
          format-plugged = "  {capacity}%";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };

        network = {
          format-wifi = "󰤨  {signalStrength}%";
          format-ethernet = "󰈀  {ipaddr}";
          format-disconnected = "󰤭  Off";
          tooltip-format = "{essid} ({signalStrength}%)\n{ifname}: {ipaddr}/{cidr}";
        };

        bluetooth = {
          format = "  {status}";
          format-connected = "  {num_connections}";
          format-disabled = "";
          tooltip-format = "{controller_alias}\n{num_connections} connected";
          on-click = "blueman-manager";
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "󰝟  Muted";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
          on-click = "pavucontrol";
        };

        backlight = {
          format = "󰃟  {percent}%";
        };

        tray = {
          icon-size = 18;
          spacing = 8;
        };
      };
    };

    # ── Catppuccin Mocha CSS ──
    style = ''
      /* Catppuccin Mocha palette */
      @define-color base #1e1e2e;
      @define-color mantle #181825;
      @define-color crust #11111b;
      @define-color text #cdd6f4;
      @define-color subtext0 #a6adc8;
      @define-color subtext1 #bac2de;
      @define-color surface0 #313244;
      @define-color surface1 #45475a;
      @define-color surface2 #585b70;
      @define-color overlay0 #6c7086;
      @define-color blue #89b4fa;
      @define-color lavender #b4befe;
      @define-color sapphire #74c7ec;
      @define-color sky #89dceb;
      @define-color teal #94e2d5;
      @define-color green #a6e3a1;
      @define-color yellow #f9e2af;
      @define-color peach #fab387;
      @define-color maroon #eba0ac;
      @define-color red #f38ba8;
      @define-color mauve #cba6f7;
      @define-color pink #f5c2e7;
      @define-color flamingo #f2cdcd;
      @define-color rosewater #f5e0dc;

      * {
        font-family: "FiraCode Nerd Font", sans-serif;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background-color: alpha(@base, 0.85);
        color: @text;
        border-bottom: 2px solid alpha(@surface0, 0.5);
      }

      tooltip {
        background: @base;
        border: 1px solid @surface1;
        border-radius: 8px;
      }

      tooltip label {
        color: @text;
      }

      #workspaces button {
        padding: 0 8px;
        color: @overlay0;
        border-radius: 6px;
        margin: 3px 2px;
        background: transparent;
      }

      #workspaces button.active {
        color: @base;
        background: @mauve;
      }

      #workspaces button.urgent {
        color: @base;
        background: @red;
      }

      #workspaces button:hover {
        background: @surface1;
        color: @text;
      }

      #window {
        color: @subtext1;
        padding: 0 12px;
      }

      #clock {
        color: @blue;
        font-weight: bold;
      }

      #cpu {
        color: @green;
      }

      #memory {
        color: @peach;
      }

      #battery {
        color: @green;
      }

      #battery.warning {
        color: @yellow;
      }

      #battery.critical {
        color: @red;
      }

      #battery.charging {
        color: @green;
      }

      #network {
        color: @sapphire;
      }

      #network.disconnected {
        color: @overlay0;
      }

      #bluetooth {
        color: @blue;
      }

      #pulseaudio {
        color: @lavender;
      }

      #pulseaudio.muted {
        color: @overlay0;
      }

      #backlight {
        color: @yellow;
      }

      #tray {
        margin: 0 4px;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: @red;
      }

      /* Module spacing */
      #cpu, #memory, #battery, #network, #bluetooth,
      #pulseaudio, #backlight, #tray, #clock {
        padding: 0 10px;
        margin: 3px 0;
        border-radius: 6px;
        background: alpha(@surface0, 0.4);
      }
    '';
  };
}
