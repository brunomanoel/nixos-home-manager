# Uptime Kuma — service availability monitoring
# VPN only (uptime.lab). Monitors all *.local and *.brunomanoel.ninja endpoints.
{
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "127.0.0.1";
      PORT = "3001";
    };
  };

  # Nginx — VPN only
  services.nginx.virtualHosts."uptime.lab" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:3001";
      proxyWebsockets = true; # Kuma uses Socket.IO
    };
  };
}
