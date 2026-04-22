{ pkgs, ... }:
{
  # Inhibit idle (hypridle, screen blank, suspend) while a gamepad is in use.
  # Without this, hypridle locks/blanks during long gameplay since joystick
  # events don't count as user activity in Wayland.
  systemd.user.services.wljoywake = {
    Unit = {
      Description = "Wayland idle inhibit while gamepad is active";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.wljoywake}/bin/wljoywake";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
