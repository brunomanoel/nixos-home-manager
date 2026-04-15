# Nextcloud — selfhosted cloud (files, calendar, contacts)
# Runs inside CasaOS Incus container at 10.200.0.166:10081
{
  services.caddy.virtualHosts."http://nextcloud.local" = {
    extraConfig = ''
      reverse_proxy 10.200.0.166:10081
    '';
  };
  services.caddy.virtualHosts."cloud.brunomanoel.ninja" = {
    extraConfig = ''
      reverse_proxy 10.200.0.166:10081
    '';
  };
}
