# Paperclip — agent orchestration platform
# VPN only (paperclip.lab). Native systemd service via npx (official npm package).
# Database: shared Postgres instance (see ./postgresql.nix).
# Coding agent CLIs available in service path: claude-code, codex, opencode.
#
# GitHub App identity: PrêdaCoder[bot] (App ID 3587738)
# Agents commit/push as predacoder[bot] via GIT_ASKPASS + JWT token exchange.
# Token is generated on-demand by git-askpass-github-app script, cached 55 min.
{ config, pkgs, ... }:
let
  # PrêdaCoder[bot] GitHub App identity (shared with predabook via lib/github-app.nix)
  githubApp = import ../../lib/github-app.nix {
    inherit pkgs;
    lib = pkgs.lib;
    privateKeyPath = config.sops.secrets.predacoder-app-private-key.path;
    tokenCacheDir = "/var/lib/paperclip";
  };
  inherit (githubApp) gitAskpassScript ghAppToken;

  # Claude Code MCP settings for the paperclip user.
  # Generated declaratively — do not edit /var/lib/paperclip/.claude/settings.json manually.
  claudeSettings = builtins.toJSON {
    hooks = {
      PreToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = "rtk hook claude";
            }
          ];
        }
      ];
    };
    mcpServers = {
      playwright = {
        command = "${pkgs.nodejs_22}/bin/npx";
        args = [
          "-y"
          "@playwright/mcp@latest"
          "--isolated"
          "--headless"
          "--executable-path"
          "${pkgs.chromium}/bin/chromium"
          "--no-sandbox"
        ];
      };
      chrome-devtools = {
        command = "${pkgs.nodejs_22}/bin/npx";
        args = [
          "-y"
          "chrome-devtools-mcp@latest"
          "--headless"
          "--no-usage-statistics"
          "--no-performance-crux"
          "--executablePath"
          "${pkgs.chromium}/bin/chromium"
          "--no-sandbox"
        ];
      };
      nixos = {
        command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
        args = [ ];
      };
    };
  };
in
{
  # --- Postgres user/db (shared instance from ./postgresql.nix) ---
  services.postgresql = {
    ensureDatabases = [ "paperclip" ];
    ensureUsers = [
      {
        name = "paperclip";
        ensureDBOwnership = true;
      }
    ];
  };

  # --- Secrets ---
  # Format: each secret is a single KEY=VALUE line ready for systemd EnvironmentFile,
  # except `paperclip-postgres-password` which is the raw password (used by ALTER USER).
  # Generate auth/jwt with: openssl rand -base64 32
  # Generate db password with: openssl rand -base64 24 | tr -d '/+='
  sops.secrets.paperclip-better-auth-secret = {
    sopsFile = ./secrets.yaml;
    owner = "paperclip";
  };
  sops.secrets.paperclip-agent-jwt-secret = {
    sopsFile = ./secrets.yaml;
    owner = "paperclip";
  };
  # Raw password (no KEY=VALUE prefix) — read by paperclip-postgres-password.service
  sops.secrets.paperclip-postgres-password = {
    sopsFile = ./secrets.yaml;
    owner = "postgres";
  };
  # KEY=VALUE format with the same password — read by paperclip.service via EnvironmentFile
  # Format: DATABASE_URL=postgres://paperclip:SAME_PASSWORD@localhost:5432/paperclip
  sops.secrets.paperclip-database-url = {
    sopsFile = ./secrets.yaml;
    owner = "paperclip";
  };
  # PrêdaCoder GitHub App private key (.pem) — used by git-askpass-github-app for JWT signing
  sops.secrets.predacoder-app-private-key = {
    sopsFile = ./secrets.yaml;
    owner = "paperclip";
    mode = "0400";
  };

  # --- Service user ---
  users.users.paperclip = {
    isSystemUser = true;
    group = "paperclip";
    extraGroups = [ "docker" ];
    home = "/var/lib/paperclip";
    createHome = true;
  };
  users.groups.paperclip = { };

  systemd.tmpfiles.rules = [
    "d /var/lib/paperclip 0750 paperclip paperclip - -"
    "d /var/lib/paperclip/data 0750 paperclip paperclip - -"
    "d /var/lib/paperclip/.npm 0750 paperclip paperclip - -"
    "d /var/lib/paperclip/.claude 0750 paperclip paperclip - -"
  ];

  # Claude Code settings (MCP servers) — declarative, managed by NixOS.
  environment.etc."paperclip/claude-settings.json".text = claudeSettings;
  systemd.tmpfiles.settings."paperclip-claude-settings" = {
    "/var/lib/paperclip/.claude/settings.json".L.argument = "/etc/paperclip/claude-settings.json";
  };

  # --- One-shot: apply postgres password to the paperclip user from sops ---
  # Runs after postgresql is up, before paperclip starts.
  # Uses LoadCredential so the password never appears in /proc, env, or journal.
  # Idempotent: ALTER USER ... PASSWORD overwrites whatever is there.
  systemd.services.paperclip-postgres-password = {
    description = "Apply postgres password for paperclip user";
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    before = [ "paperclip.service" ];
    wantedBy = [ "paperclip.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
      LoadCredential = "password:${config.sops.secrets.paperclip-postgres-password.path}";
    };
    # Heredoc + \set keeps password out of process args and out of the journal.
    script = ''
      ${config.services.postgresql.package}/bin/psql -v ON_ERROR_STOP=1 <<EOF
      \set pwd \`cat $CREDENTIALS_DIRECTORY/password\`
      ALTER USER paperclip WITH PASSWORD :'pwd';
      EOF
    '';
  };

  # --- Paperclip server (native systemd, npm package pinned) ---
  systemd.services.paperclip = {
    description = "Paperclip — agent orchestration platform";
    after = [
      "network.target"
      "postgresql.service"
      "paperclip-postgres-password.service"
    ];
    requires = [
      "postgresql.service"
      "paperclip-postgres-password.service"
    ];
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.bash
      pkgs.nodejs_22
      pkgs.coreutils
      pkgs.git
      ghAppToken
      pkgs.gh
      pkgs.curl
      pkgs.ripgrep
      pkgs.claude-code-bin
      pkgs.codex
      pkgs.opencode
      pkgs.rtk
    ];
    environment = {
      HOME = "/var/lib/paperclip";
      NPM_CONFIG_CACHE = "/var/lib/paperclip/.npm";
      NODE_PATH = "${pkgs.nodejs_22}/lib/node_modules";
      PAPERCLIP_HOME = "/var/lib/paperclip/data";
      NODE_ENV = "production";

      # Server bind: loopback only — nginx handles VPN exposure
      HOST = "127.0.0.1";
      PORT = "3100";
      SERVE_UI = "true";

      # DATABASE_URL is set via EnvironmentFile (sops.paperclip-database-url)
      # because Paperclip's official docs only support postgres://user:pass@host:port/db.
      # Postgres password is applied declaratively by paperclip-postgres-password.service.

      # Deployment: authenticated multi-user, private (VPN-only)
      PAPERCLIP_DEPLOYMENT_MODE = "authenticated";
      PAPERCLIP_DEPLOYMENT_EXPOSURE = "private";
      PAPERCLIP_PUBLIC_URL = "https://paperclip.brunomanoel.ninja";
      PAPERCLIP_ALLOWED_HOSTNAMES = "paperclip.brunomanoel.ninja,paperclip.lab";

      PAPERCLIP_TELEMETRY_DISABLED = "1";
      OPENCODE_ALLOW_ALL_MODELS = "true";

      # --- PrêdaCoder[bot] GitHub App identity ---
      # Git identity via env vars (no .gitconfig needed for system users)
      GIT_AUTHOR_NAME = "PrêdaCoder[bot]";
      GIT_AUTHOR_EMAIL = "281405911+predacoder[bot]@users.noreply.github.com";
      GIT_COMMITTER_NAME = "PrêdaCoder[bot]";
      GIT_COMMITTER_EMAIL = "281405911+predacoder[bot]@users.noreply.github.com";

      # GIT_ASKPASS: on-demand GitHub App token generation (JWT dance + 55 min cache)
      GIT_ASKPASS = "${gitAskpassScript}";
      GIT_TERMINAL_PROMPT = "0";

      # URL rewrite: embed x-access-token as username so git calls GIT_ASKPASS for password
      GIT_CONFIG_COUNT = "1";
      GIT_CONFIG_KEY_0 = "url.https://x-access-token@github.com/.insteadOf";
      GIT_CONFIG_VALUE_0 = "https://github.com/";
    };
    serviceConfig = {
      Type = "simple";
      User = "paperclip";
      Group = "paperclip";
      WorkingDirectory = "/var/lib/paperclip";
      EnvironmentFile = [
        config.sops.secrets.paperclip-better-auth-secret.path
        config.sops.secrets.paperclip-agent-jwt-secret.path
        config.sops.secrets.paperclip-database-url.path
      ];

      # Pin version explicitly. Update: bump the version string.
      # `onboard --yes --run` is idempotent: first time creates config from defaults +
      # env vars, subsequent times detects existing config and proceeds to run.
      # `--bind lan` is required so onboard respects PAPERCLIP_DEPLOYMENT_MODE env var
      # (without it, --yes forces local_trusted which blocks paperclip.lab access via nginx).
      ExecStart = "${pkgs.nodejs_22}/bin/npx -y paperclipai@2026.428.0 onboard --yes --bind lan --run --data-dir /var/lib/paperclip/data";

      Restart = "on-failure";
      RestartSec = 10;
      TimeoutStartSec = 600; # First start downloads npm package
    };
  };

  # --- Nginx reverse proxy ---
  # proxyWebsockets = true already sets proxy_http_version 1.1 + Upgrade/Connection headers

  # Public HTTPS (internet-facing, ACME cert)
  services.nginx.virtualHosts."paperclip.brunomanoel.ninja" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3100";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
      '';
    };
  };

  # VPN only (WireGuard) — proxy to public vhost so cookies/auth work
  services.nginx.virtualHosts."paperclip.lab" = {
    locations."/" = {
      proxyPass = "https://paperclip.brunomanoel.ninja";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host paperclip.brunomanoel.ninja;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_ssl_verify off;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
      '';
    };
  };
}
