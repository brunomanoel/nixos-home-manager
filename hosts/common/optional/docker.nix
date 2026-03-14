{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false; # socket-activated on first docker command
    listenOptions = [
      "/var/run/docker.sock"
    ];
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };
}
