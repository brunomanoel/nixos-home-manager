# ThingsBoard CE — IoT platform
# Runs as Docker container on localhost:8090
{
  services.caddy.virtualHosts."http://thingsboard.local" = {
    extraConfig = ''
      reverse_proxy localhost:8090
    '';
  };
  services.caddy.virtualHosts."thingsboard.brunomanoel.ninja" = {
    extraConfig = ''
      reverse_proxy localhost:8090
    '';
  };
}
