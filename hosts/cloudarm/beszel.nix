# Beszel — lightweight host monitoring (CPU, RAM, disk, docker)
# VPN only (beszel.local). Hub + local agent on cloudarm.
# Remote agents (predabook, wsl) added later via their own host configs.
{
  services.beszel.hub = {
    enable = true;
    host = "127.0.0.1";
    port = 8090; # default; ThingsBoard moved to :18090 to free this port
  };

  services.beszel.agent = {
    enable = true;
    # Listens on :45876 by default, hub connects via SSH
  };

  # Nginx — VPN only
  services.nginx.virtualHosts."beszel.local" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:8090";
      proxyWebsockets = true;
    };
  };
}
