# CasaOS — selfhosted app store (WireGuard only, not publicly exposed)
# Runs inside Incus (Debian 12) container at 10.200.0.166
{ pkgs, ... }:
{
  # --- Incus (LXC containers) ---
  virtualisation.incus = {
    enable = true;
    preseed = {
      profiles = [
        {
          name = "default";
          devices = {
            root = {
              path = "/";
              pool = "default";
              type = "disk";
            };
            eth0 = {
              name = "eth0";
              network = "incusbr0";
              type = "nic";
            };
          };
        }
      ];
      networks = [
        {
          name = "incusbr0";
          type = "bridge";
          config = {
            "ipv4.address" = "10.200.0.1/24";
            "ipv4.nat" = "true";
          };
        }
      ];
      storage_pools = [
        {
          name = "default";
          driver = "dir";
        }
      ];
    };
  };

  # Nginx virtualhost (WireGuard only)
  services.nginx.virtualHosts."casaos.local" = {
    locations."/".proxyPass = "http://10.200.0.166:80";
  };

  # Auto-provision container
  # Creates Debian 12 container with CasaOS if not exists
  systemd.services.casaos-provision = {
    description = "Provision CasaOS Incus container";
    after = [
      "incus.service"
      "incus-preseed.service"
    ];
    requires = [ "incus.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.incus ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Skip if container already exists
      if incus info casaos &>/dev/null; then
        echo "CasaOS container already exists — skipping"
        exit 0
      fi

      echo "Creating CasaOS container..."
      incus launch images:debian/12 casaos \
        --config security.nesting=true \
        --config security.privileged=true

      echo "Waiting for container to start..."
      sleep 10

      echo "Mounting persistent data directory..."
      incus config device add casaos appdata disk \
        source=/srv/casaos/data \
        path=/DATA

      echo "Installing Docker and CasaOS..."
      incus exec casaos -- bash -c 'apt-get update -qq && apt-get install -y -qq curl docker.io > /dev/null 2>&1'
      incus exec casaos -- bash -c 'curl -fsSL https://get.casaos.io | bash'

      echo "CasaOS provisioned successfully"
    '';
  };

  # Persistent storage
  systemd.tmpfiles.rules = [
    "d /srv/casaos/data 0755 root root -"
  ];
}
