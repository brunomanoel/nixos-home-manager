# Nextcloud — selfhosted cloud (files, calendar, contacts)
# Runs natively on NixOS with PostgreSQL
# Nginx is configured automatically by the Nextcloud module
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
      adminpassFile = "/etc/nextcloud-admin-pass";
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
        contacts
        calendar
        tasks
        ;
    };
    extraAppsEnable = true;
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
  # VPN access
  services.nginx.virtualHosts."nextcloud.local" = {
    locations."/".proxyPass = "http://127.0.0.1:80";
  };
}
