{
  config,
  pkgs,
  lib,
  ...
}:

let
  pelicanVersion = "1.0.0-beta25";
  pelicanSrc = pkgs.fetchurl {
    url = "https://github.com/pelican-dev/panel/releases/latest/download/panel.tar.gz";
    hash = ""; # TODO: fill after first download
  };
  wingsVersion = "1.0.0-beta24";
  wingsBin = pkgs.fetchurl {
    url = "https://github.com/pelican-dev/wings/releases/download/v${wingsVersion}/wings_linux_arm64";
    hash = ""; # TODO: fill after first download
    executable = true;
  };
  php = pkgs.php83.withExtensions (
    { enabled, all }:
    enabled
    ++ (with all; [
      gd
      mbstring
      bcmath
      xml
      curl
      zip
      intl
      sqlite3
      pdo_sqlite
    ])
  );
  dataDir = "/var/lib/pelican";
in
{
  # PHP-FPM for Pelican
  services.phpfpm.pools.pelican = {
    user = "pelican";
    group = "pelican";
    settings = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;
      "pm" = "dynamic";
      "pm.max_children" = 4;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 3;
    };
    phpPackage = php;
  };

  # Caddy reverse proxy
  services.caddy = {
    enable = true;
    virtualHosts.":80" = {
      extraConfig = ''
        root * ${dataDir}/public
        php_fastcgi unix/${config.services.phpfpm.pools.pelican.socket}
        file_server
      '';
    };
  };

  # Wings daemon
  systemd.services.wings = {
    description = "Pelican Wings Daemon";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${wingsBin}";
      Restart = "on-failure";
      RestartSec = 5;
      LimitNOFILE = 4096;
    };
  };

  # Pelican system user
  users.users.pelican = {
    isSystemUser = true;
    group = "pelican";
    home = dataDir;
    createHome = true;
  };
  users.groups.pelican = { };

  # Required directories
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 pelican pelican -"
    "d ${dataDir}/storage 0750 pelican pelican -"
    "d /etc/pelican 0750 pelican pelican -"
    "d /var/log/pelican 0750 pelican pelican -"
  ];
}
