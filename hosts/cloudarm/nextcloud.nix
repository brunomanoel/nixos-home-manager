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
    package = pkgs.nextcloud33;
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
    };

    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps)
        # PIM
        contacts
        calendar
        tasks

        # Sync & performance
        notify_push
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
  services.nextcloud-whiteboard.enable = true;

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
  # Public HTTPS (Nextcloud module already configures this vhost, just add TLS)
  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    forceSSL = true;
    enableACME = true;
  };
  # VPN access — same config as public vhost but without SSL
  services.nginx.virtualHosts."nextcloud.local" =
    config.services.nginx.virtualHosts.${config.services.nextcloud.hostName}
    // {
      forceSSL = false;
      enableACME = false;
    };
}
