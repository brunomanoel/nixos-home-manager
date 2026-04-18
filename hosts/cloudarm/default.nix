# Oracle Cloud A1.Flex — 4 ARM cores (Ampere Altra), 24GB RAM, 200GB disk
# Purpose: remote code RAG server (Ollama + Qdrant + MCP services via supergateway)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    inputs.home-manager-stable.nixosModules.home-manager
    ../common/global
    ../common/optional/openssh.nix
    ../common/users/bruno
    ./pelican.nix
    ./casaos.nix
    ./thingsboard.nix
    ./nextcloud.nix
    ./claude-proxy.nix
    ./n8n.nix
    ./uptime-kuma.nix
    ./beszel.nix
  ];

  system.stateVersion = "23.11"; # Set by nixos-infect — do not change

  # --- Boot ---
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.configurationLimit = 5;

  # Default channel kernel — conservative choice for cloud server stability

  # zram swap — no physical swap on cloud
  zramSwap.enable = true;

  # --- Networking ---
  networking.hostName = "cloudarm";
  networking.useDHCP = true; # Oracle Cloud assigns IP via DHCP

  # Firewall disabled — Oracle Cloud Security List handles public filtering.
  # Exposing only SSH (22/TCP) and WireGuard (51820/UDP) at the OCI level.
  # All other services (Ollama, Qdrant, MCPs) are accessible only via WireGuard tunnel.
  networking.firewall.enable = false;

  # IP forwarding — roteia pacotes entre wg0 (10.100.0.0/24) e incusbr0
  # (10.200.0.0/24). Permite que peers WG acessem containers Incus (ex:
  # predabook → casaos.local:8100 → container CasaOS).
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # --- Secrets (sops-nix) ---
  sops.secrets.wireguard-private-key.sopsFile = ./secrets.yaml;

  # --- WireGuard ---
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets.wireguard-private-key.path;

    peers = [
      {
        # predabook
        publicKey = "bGDWAUyi6eXyv766BeFVsbU/trma2WUjVuOYZUJN/mE=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
      # mac (10.100.0.3) — add peer when key is generated
      {
        # wsl
        publicKey = "CVxISNMKGh+QhFWhyaUJFy/dpwKIPiF7vMTzF6xz4j8=";
        allowedIPs = [ "10.100.0.4/32" ];
      }
    ];
  };

  # --- Docker ---
  virtualisation.docker.enable = true;

  # --- Nginx + ACME ---
  services.nginx.enable = true;
  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@brunomanoel.ninja";
  };

  security.sudo.wheelNeedsPassword = false;

  # SSH hardening — sshd enabled via ../common/optional/openssh.nix

  # Add bruno to container/docker groups
  users.users.bruno.extraGroups = [
    "incus-admin"
    "docker"
  ];

  # SSH keys shared across users — cloudarm (Oracle) + predabook (personal)
  users.users.bruno.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDqEFTEOwUFIpboG2ZNlvLSvVJtnKVGicbJY84+63UArxwPd6t4ErcLp/m6NUN+pANLEcFBEM8veDkGvKGPqUAJZvLX0wdkRo8mvj/8OZ6AbCQmUQ62lYiBUpPa1xGdvEiGyCVNHp+IyFDjm9VvOTUMaOp+Afw3fCx9DwV3+r0CnEn7Scdfhc6iQak0xfLPbXyHRbcQ3762z57hW1qWsYWApNKb6qGy38jzBznfwZu6UIfmsQ9AOsvSTeXysIGKqR5/gck03fpR0CwVpoXRgCQG2b019bK4DDDEvvmnCYjf8z4iq4WXTk66AM/p5oQKR1uspV93cUshHsuaenrO+ySJ cloudarm"
  ];

  # Oracle Cloud default user — kept for console/compatibility access
  users.users.ubuntu = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDqEFTEOwUFIpboG2ZNlvLSvVJtnKVGicbJY84+63UArxwPd6t4ErcLp/m6NUN+pANLEcFBEM8veDkGvKGPqUAJZvLX0wdkRo8mvj/8OZ6AbCQmUQ62lYiBUpPa1xGdvEiGyCVNHp+IyFDjm9VvOTUMaOp+Afw3fCx9DwV3+r0CnEn7Scdfhc6iQak0xfLPbXyHRbcQ3762z57hW1qWsYWApNKb6qGy38jzBznfwZu6UIfmsQ9AOsvSTeXysIGKqR5/gck03fpR0CwVpoXRgCQG2b019bK4DDDEvvmnCYjf8z4iq4WXTk66AM/p5oQKR1uspV93cUshHsuaenrO+ySJ cloudarm"
    ];
  };

  # Root also needs the key — nixos-infect initial access + emergency recovery
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDqEFTEOwUFIpboG2ZNlvLSvVJtnKVGicbJY84+63UArxwPd6t4ErcLp/m6NUN+pANLEcFBEM8veDkGvKGPqUAJZvLX0wdkRo8mvj/8OZ6AbCQmUQ62lYiBUpPa1xGdvEiGyCVNHp+IyFDjm9VvOTUMaOp+Afw3fCx9DwV3+r0CnEn7Scdfhc6iQak0xfLPbXyHRbcQ3762z57hW1qWsYWApNKb6qGy38jzBznfwZu6UIfmsQ9AOsvSTeXysIGKqR5/gck03fpR0CwVpoXRgCQG2b019bK4DDDEvvmnCYjf8z4iq4WXTk66AM/p5oQKR1uspV93cUshHsuaenrO+ySJ cloudarm"
  ];

  # --- Playwright MCP (native SSE transport, headless Chromium) ---
  # Runs as a systemd service, accessible via WireGuard on port 8002
  systemd.services.playwright-mcp = {
    description = "Playwright MCP Server (headless)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.bash
      pkgs.nodejs_22
      pkgs.coreutils
    ];
    environment = {
      HOME = "/var/lib/playwright-mcp";
      NODE_PATH = "${pkgs.nodejs_22}/lib/node_modules";
    };
    serviceConfig = {
      Type = "simple";
      StateDirectory = "playwright-mcp";
      ExecStart = "${pkgs.nodejs_22}/bin/npx -y @playwright/mcp@latest --port 8002 --headless --host 0.0.0.0 --allowed-hosts '*' --executable-path ${pkgs.chromium}/bin/chromium --no-sandbox";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # --- System packages ---
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    chromium # required by Playwright
    claude-code-bin
  ];

  # --- Headless server: no desktop ---
  # No GNOME, no Hyprland, no sound, no printing
}
