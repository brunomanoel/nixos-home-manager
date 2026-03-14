{
  services.mako = {
    enable = true;
    settings = {
      background-color = "#1e1e2eff";
      text-color = "#cdd6f4ff";
      border-color = "#cba6f7ff";
      border-size = 2;
      border-radius = 8;
      default-timeout = 5000;
      font = "FiraCode Nerd Font 12";
      margin = "8";
      padding = "12";
      width = 350;
      max-visible = 3;
      layer = "overlay";

      "[urgency=low]" = {
        border-color = "#89b4faff";
      };

      "[urgency=critical]" = {
        border-color = "#f38ba8ff";
        default-timeout = 0;
      };
    };
  };
}
