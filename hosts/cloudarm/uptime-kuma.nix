# Uptime Kuma — service availability monitoring
# VPN only (uptime.local). Monitors all *.local and *.brunomanoel.ninja endpoints.
{
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "127.0.0.1";
      PORT = "3001";
    };
  };

  # Nginx — VPN only
  services.nginx.virtualHosts."uptime.local" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:3001";
      proxyWebsockets = true; # Kuma uses Socket.IO
    };
  };
}
