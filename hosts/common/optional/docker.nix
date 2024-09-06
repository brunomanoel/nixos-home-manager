{
  virtualisation.docker = {
    enable = true;
    listenOptions = [
      "/var/run/docker.sock"
    ];
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };
}
