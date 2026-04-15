# ThingsBoard CE — IoT platform
# Runs as Docker container on localhost:8090
{
  # VPN access
  services.nginx.virtualHosts."thingsboard.local" = {
    locations."/".proxyPass = "http://localhost:8090";
  };
  # Public HTTPS
  services.nginx.virtualHosts."thingsboard.brunomanoel.ninja" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://localhost:8090";
  };
}
