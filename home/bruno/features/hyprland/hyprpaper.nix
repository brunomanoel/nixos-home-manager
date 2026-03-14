{ config, ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      # To set a wallpaper, add the image to ~/Pictures/wallpapers/
      # and uncomment the lines below:
      # preload = [ "~/Pictures/wallpapers/wallpaper.jpg" ];
      # wallpaper = [
      #   ", ~/Pictures/wallpapers/wallpaper.jpg"
      # ];
    };
  };
}
