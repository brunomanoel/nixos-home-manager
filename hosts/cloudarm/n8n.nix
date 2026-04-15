# n8n — workflow automation
# VPN only for now. Public access may be needed later for:
# - Webhooks: external services (GitHub, Telegram, etc) triggering workflows
# - Sharing: exposing workflows/endpoints for other people or apps
# When needed: add public virtualhost (e.g. n8n.brunomanoel.ninja) for /webhook/ only, keep UI on VPN
{
  services.n8n = {
    enable = true;
    environment = {
      GENERIC_TIMEZONE = "America/Sao_Paulo";
      N8N_SECURE_COOKIE = "false"; # VPN only, no HTTPS
    };
  };

  # Nginx — VPN only
  services.nginx.virtualHosts."n8n.local" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:5678";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
      '';
    };
  };
}
