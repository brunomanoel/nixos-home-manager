# DNS server for the WireGuard subnet
# Resolves *.lab → 10.100.0.1 (cloudarm WG IP) for any peer connected to wg0.
# Each peer needs `DNS = 10.100.0.1` in its WireGuard interface config.
# Adding a new internal service: just create services.nginx.virtualHosts."x.lab"
# in any module — no host edits needed on any client.
{ config, pkgs, ... }:
{
  services.dnsmasq = {
    enable = true;
    settings = {
      # Listen only on the WireGuard interface — never expose DNS publicly
      interface = "wg0";
      bind-interfaces = true;

      # Wildcard: any *.lab resolves to cloudarm's WG address
      # Exceptions for services on different subnets (e.g. Incus containers)
      address = [
        "/casaos.lab/10.200.0.166" # CasaOS lives in Incus subnet
        "/lab/10.100.0.1" # everything else → cloudarm
      ];

      # Forward all other queries to upstream
      server = [
        "1.1.1.1"
        "1.0.0.1"
      ];

      # Don't read /etc/hosts (avoids leaking host names)
      no-hosts = true;

      cache-size = 1000;
    };
  };

  # Allow DNS only via WireGuard
  networking.firewall.interfaces.wg0 = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
