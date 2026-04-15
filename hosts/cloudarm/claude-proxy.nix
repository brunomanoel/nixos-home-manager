# Claude Max Proxy — reverse proxy for Claude CLI
# Accepts authenticated POST /enrich requests, runs claude CLI with JSON schema output
# Allows external backend (Firebase Functions) to use Claude Max plan via proxy
{ config, pkgs, ... }:
{
  # Deploy the script
  environment.etc."claude-proxy/server.js".source = ./claude-proxy-server.js;

  # Systemd service
  systemd.services.claude-proxy = {
    description = "Claude Max Proxy";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.claude-code-bin ];
    environment = {
      HOME = "/var/lib/claude-proxy/home";
    };
    serviceConfig = {
      ExecStart = "${pkgs.nodejs_22}/bin/node /etc/claude-proxy/server.js";
      EnvironmentFile = config.sops.secrets.claude-proxy-token.path;
      WorkingDirectory = "/var/lib/claude-proxy";
      Restart = "on-failure";
      RestartSec = 5;
      Type = "simple";
    };
  };

  # Persistent state for Claude CLI
  systemd.tmpfiles.rules = [
    "d /var/lib/claude-proxy 0700 root root -"
    "d /var/lib/claude-proxy/home 0700 root root -"
  ];

  # Secret
  sops.secrets.claude-proxy-token = {
    sopsFile = ./secrets.yaml;
  };

  # Nginx — public HTTPS
  services.nginx.virtualHosts."ai.brunomanoel.ninja" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3333";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}
