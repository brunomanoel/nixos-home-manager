# SearXNG — privacy-respecting meta search engine
# VPN only (searx.lab). Used by Claude Code, OpenCode, and Pi via MCP.
# Secret key is injected via sops environment file to avoid nix store exposure.
{ config, pkgs, ... }:
{
  sops.secrets.searx-secret-key = {
    sopsFile = ./secrets.yaml;
    owner = "searx";
  };

  services.searx = {
    enable = true;
    package = pkgs.searxng;
    environmentFile = config.sops.secrets.searx-secret-key.path;
    settings = {
      use_default_settings = true;
      server = {
        bind_address = "127.0.0.1";
        port = 8888;
        secret_key = "$SEARX_SECRET_KEY";
        limiter = false; # VPN only — no rate limiting needed
      };
      search = {
        safe_search = 0;
        autocomplete = "";
        formats = [
          "html"
          "json"
        ];
      };
      ui = {
        default_locale = "en";
        default_theme = "simple";
      };
    };
  };

  # Nginx — VPN only
  services.nginx.virtualHosts."searx.lab" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:8888";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}
