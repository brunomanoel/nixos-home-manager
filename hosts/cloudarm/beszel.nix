# Beszel — lightweight host monitoring (CPU, RAM, disk, docker)
# VPN only (beszel.lab). Hub + local agent on cloudarm.
# Remote agents (predabook, wsl) added later via their own host configs.
{
  services.beszel.hub = {
    enable = true;
    host = "127.0.0.1";
    port = 8090; # default; ThingsBoard moved to :18090 to free this port
  };

  services.beszel.agent = {
    enable = true;
    # Public SSH key from hub UI (Add System dialog). Safe in git.
    environment.KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0ltIF6sdCmOYdUJMH0Qaw/X1JCcowrqvDel+RWKUUO";
  };

  # Nginx — VPN only
  services.nginx.virtualHosts."beszel.lab" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:8090";
      proxyWebsockets = true;
    };
  };
}
