# POC reverse proxies — ephemeral containers exposed via *.poc.brunomanoel.ninja
# DNS: wildcard A record *.poc.brunomanoel.ninja → cloudarm public IP
# ACME: individual HTTP-01 per subdomain (no wildcard cert needed)
#
# To add a new POC: add entry to the attrset below and deploy.
# To remove: delete entry and deploy (or just stop the container).
let
  pocs = {
    zabbix = 8099;
    grafana = 3000;
  };
  mkPocVhost = name: port: {
    name = "${name}.poc.brunomanoel.ninja";
    value = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_read_timeout 600s;
        '';
      };
    };
  };
in
{
  services.nginx.virtualHosts = builtins.listToAttrs (
    builtins.map (name: mkPocVhost name pocs.${name}) (builtins.attrNames pocs)
  );
}
