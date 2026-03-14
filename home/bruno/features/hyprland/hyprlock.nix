{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 5;
        hide_cursor = true;
      };

      background = [{
        monitor = "";
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
        noise = 1.17e-2;
        contrast = 0.8916;
        brightness = 0.8172;
        vibrancy = 0.1696;
      }];

      input-field = [{
        monitor = "";
        size = "300, 50";
        outline_thickness = 2;
        dots_size = 0.2;
        dots_spacing = 0.35;
        dots_center = true;
        outer_color = "rgb(cba6f7)";    # mauve
        inner_color = "rgb(313244)";    # surface0
        font_color = "rgb(cdd6f4)";     # text
        fade_on_empty = false;
        placeholder_text = "Password...";
        hide_input = false;
        position = "0, -80";
        halign = "center";
        valign = "center";
      }];

      label = [
        {
          # Time
          monitor = "";
          text = "$TIME";
          color = "rgb(cdd6f4)";        # text
          font_size = 72;
          font_family = "FiraCode Nerd Font";
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
        {
          # Date
          monitor = "";
          text = "cmd[update:3600000] date +'%A, %d %B'";
          color = "rgb(bac2de)";        # subtext1
          font_size = 18;
          font_family = "FiraCode Nerd Font";
          position = "0, 30";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
