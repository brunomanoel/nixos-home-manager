# Nextcloud — selfhosted cloud (files, calendar, contacts, collaboration)
# Runs natively on NixOS with PostgreSQL
# Nginx is configured automatically by the Nextcloud module
#
# Nice to have (not yet added):
# - onlyoffice: better MSOffice compatibility than Collabora, but no official ARM image
{ config, pkgs, ... }:
{
  # --- Nextcloud ---
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = "cloud.brunomanoel.ninja";
    https = true;
    maxUploadSize = "1G";

    config = {
      adminpassFile = config.sops.secrets.nextcloud-admin-pass.path;
      dbtype = "pgsql";
    };

    database.createLocally = true;

    settings = {
      trusted_domains = [
        "cloud.brunomanoel.ninja"
        "nextcloud.local"
      ];
      overwriteprotocol = "https";
      trusted_proxies = [
        "127.0.0.1"
        "::1"
        "137.131.233.96"
      ];
      maintenance_window_start = 2; # 2:00 UTC
      default_phone_region = "BR";
      "integrity.check.disabled" = true; # extraApps via nix breaks integrity check
    };

    phpOptions."opcache.interned_strings_buffer" = "16";

    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps)
        # PIM
        contacts
        calendar
        tasks

        # Sync & performance
        previewgenerator
        dav_push

        # Security
        twofactor_webauthn

        # Productivity
        deck
        forms
        collectives
        whiteboard

        # Files & media
        bookmarks
        memories
        recognize

        # Communication
        spreed

        # Finance
        cospend

        # Tracking
        phonetrack

        # Documents
        richdocuments
        integration_paperless

        # Multi-user
        sociallogin
        guests
        groupfolders
        ;
    };
    extraAppsEnable = true;
  };

  # --- Notify Push (instant sync notifications via websocket) ---
  services.nextcloud.notify_push.enable = true;

  # --- Whiteboard Server ---
  services.nextcloud-whiteboard-server = {
    enable = true;
    settings = {
      NEXTCLOUD_URL = "https://cloud.brunomanoel.ninja";
      CHROME_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";
    };
    secrets = [ config.sops.templates.whiteboard-jwt-env.path ];
  };
  sops.secrets.whiteboard-jwt-secret = {
    sopsFile = ./secrets.yaml;
    owner = "nextcloud";
    group = "nextcloud";
  };
  sops.templates.whiteboard-jwt-env = {
    content = "JWT_SECRET_KEY=${config.sops.placeholder.whiteboard-jwt-secret}";
  };

  # Configure whiteboard app in Nextcloud via occ (semi-declarative)
  systemd.services.nextcloud-whiteboard-config = {
    path = [ config.services.nextcloud.occ ];
    script = ''
      nextcloud-occ config:app:set whiteboard collabBackendUrl --value="https://cloud.brunomanoel.ninja/whiteboard/"
      nextcloud-occ config:app:set whiteboard jwt_secret_key --value="$(cat ${config.sops.secrets.whiteboard-jwt-secret.path})"
      nextcloud-occ config:app:set richdocuments wopi_url --value="https://cloud.brunomanoel.ninja/"
    '';
    after = [ "nextcloud-setup.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "nextcloud";
    };
  };

  # --- Collabora Online (document editing, alternative to OnlyOffice) ---
  services.collabora-online = {
    enable = true;
    port = 9980;
    aliasGroups = [
      {
        host = "https://cloud.brunomanoel.ninja:443";
        aliases = [ "https://nextcloud\\.local" ];
      }
    ];
    settings = {
      ssl.enable = false; # Nginx handles SSL
      ssl.termination = true;
    };
  };

  # --- Paperless-ngx (document scanning, OCR, archival) ---
  services.paperless = {
    enable = true;
    passwordFile = config.sops.secrets.paperless-admin-pass.path;
    settings = {
      PAPERLESS_OCR_LANGUAGE = "por+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [
        ".DS_STORE/*"
        "desktop.ini"
      ];
      PAPERLESS_URL = "http://paperless.local";
    };
  };
  sops.secrets.paperless-admin-pass = {
    sopsFile = ./secrets.yaml;
    owner = "paperless";
    group = "paperless";
  };
  # Nginx reverse proxy for Paperless (VPN only)
  services.nginx.virtualHosts."paperless.local" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:28981";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };

  # --- Secrets ---
  sops.secrets.nextcloud-admin-pass = {
    sopsFile = ./secrets.yaml;
    owner = "nextcloud";
    group = "nextcloud";
  };

  # --- PostgreSQL (managed by Nextcloud module via createLocally) ---
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
  };

  # --- Nginx virtualhosts ---
  # Public HTTPS
  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    forceSSL = true;
    enableACME = true;
    # Collabora Online proxy (SSL termination)
    locations."^~ /browser" = {
      proxyPass = "http://127.0.0.1:9980";
      extraConfig = "proxy_set_header Host $host;";
    };
    locations."^~ /hosting/discovery" = {
      proxyPass = "http://127.0.0.1:9980";
      extraConfig = "proxy_set_header Host $host;";
    };
    locations."^~ /hosting/capabilities" = {
      proxyPass = "http://127.0.0.1:9980";
      extraConfig = "proxy_set_header Host $host;";
    };
    locations."~ ^/cool/(.*)/ws$" = {
      proxyPass = "http://127.0.0.1:9980";
      extraConfig = ''
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_read_timeout 36000s;
      '';
    };
    locations."^~ /cool/adminws" = {
      proxyPass = "http://127.0.0.1:9980";
      extraConfig = ''
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_read_timeout 36000s;
      '';
    };
    locations."~ ^/cool" = {
      proxyPass = "http://127.0.0.1:9980";
      extraConfig = "proxy_set_header Host $host;";
    };
    # Whiteboard websocket proxy
    locations."/whiteboard/" = {
      proxyPass = "http://localhost:3002/";
      extraConfig = ''
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
      '';
    };
  };
  # VPN access — proxy to the main Nextcloud vhost (no SSL)
  services.nginx.virtualHosts."nextcloud.local" = {
    locations."/" = {
      proxyPass = "https://cloud.brunomanoel.ninja";
      extraConfig = ''
        proxy_set_header Host cloud.brunomanoel.ninja;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_ssl_verify off;
      '';
    };
  };
}
