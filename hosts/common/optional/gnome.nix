{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  services.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = (
    with pkgs;
    [
      gnome-photos
      gnome-tour
      cheese # webcam tool
      gnome-terminal
      gedit # text editor
      epiphany # web browser
      geary # email reader
      evince # document viewer
      totem # video player
      gnome-music
      gnome-characters
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      gnome-maps
      gnome-contacts
      gnome-weather
      gnome-connections
      simple-scan
      gnome-calculator
    ]
  );
  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

  programs.dconf.enable = true; # https://nixos.wiki/wiki/GNOME

  programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;

  # gnome-keyring disabled — KeePassXC provides Secret Service (org.freedesktop.secrets)
  # VS Code auth tokens, Chromium Safe Storage, etc. are served by KeePassXC.
  services.gnome.gnome-keyring.enable = false;

  # Disable GNOME's SSH agent — OpenSSH agent is used instead (programs.ssh.startAgent)
  services.gnome.gcr-ssh-agent.enable = false;

  services.gnome.gnome-browser-connector.enable = true;
}
