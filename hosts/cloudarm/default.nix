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
    ../common/users/bruno
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

  # --- WireGuard ---
  # Private key stored at /etc/wireguard/private.key (not in repo)
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/etc/wireguard/private.key";

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

  # --- SSH hardening ---
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # SSH keys shared across users — cloudarm (Oracle) + predabook (personal)
  users.users.bruno.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDqEFTEOwUFIpboG2ZNlvLSvVJtnKVGicbJY84+63UArxwPd6t4ErcLp/m6NUN+pANLEcFBEM8veDkGvKGPqUAJZvLX0wdkRo8mvj/8OZ6AbCQmUQ62lYiBUpPa1xGdvEiGyCVNHp+IyFDjm9VvOTUMaOp+Afw3fCx9DwV3+r0CnEn7Scdfhc6iQak0xfLPbXyHRbcQ3762z57hW1qWsYWApNKb6qGy38jzBznfwZu6UIfmsQ9AOsvSTeXysIGKqR5/gck03fpR0CwVpoXRgCQG2b019bK4DDDEvvmnCYjf8z4iq4WXTk66AM/p5oQKR1uspV93cUshHsuaenrO+ySJ cloudarm"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINoNlaCDSgLyGcjpNa4BA1PA/lXO5VIDyxSaCSAK8csa 26349861+brunomanoel@users.noreply.github.com"
  ];

  # Oracle Cloud default user — kept for console/compatibility access
  users.users.ubuntu = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDqEFTEOwUFIpboG2ZNlvLSvVJtnKVGicbJY84+63UArxwPd6t4ErcLp/m6NUN+pANLEcFBEM8veDkGvKGPqUAJZvLX0wdkRo8mvj/8OZ6AbCQmUQ62lYiBUpPa1xGdvEiGyCVNHp+IyFDjm9VvOTUMaOp+Afw3fCx9DwV3+r0CnEn7Scdfhc6iQak0xfLPbXyHRbcQ3762z57hW1qWsYWApNKb6qGy38jzBznfwZu6UIfmsQ9AOsvSTeXysIGKqR5/gck03fpR0CwVpoXRgCQG2b019bK4DDDEvvmnCYjf8z4iq4WXTk66AM/p5oQKR1uspV93cUshHsuaenrO+ySJ cloudarm"
    ];
  };

  # Root also needs the key — nixos-infect initial access + emergency recovery
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDqEFTEOwUFIpboG2ZNlvLSvVJtnKVGicbJY84+63UArxwPd6t4ErcLp/m6NUN+pANLEcFBEM8veDkGvKGPqUAJZvLX0wdkRo8mvj/8OZ6AbCQmUQ62lYiBUpPa1xGdvEiGyCVNHp+IyFDjm9VvOTUMaOp+Afw3fCx9DwV3+r0CnEn7Scdfhc6iQak0xfLPbXyHRbcQ3762z57hW1qWsYWApNKb6qGy38jzBznfwZu6UIfmsQ9AOsvSTeXysIGKqR5/gck03fpR0CwVpoXRgCQG2b019bK4DDDEvvmnCYjf8z4iq4WXTk66AM/p5oQKR1uspV93cUshHsuaenrO+ySJ cloudarm"
  ];

  # --- WireGuard ---
  # TODO: Configure after defining subnet, peers, and IP
  # networking.wireguard.interfaces.wg0 = {
  #   ips = [ "10.100.0.1/24" ];
  #   listenPort = 51820;
  #   privateKeyFile = "/etc/wireguard/private.key";
  #   peers = [
  #     {
  #       # predabook
  #       publicKey = "TODO";
  #       allowedIPs = [ "10.100.0.2/32" ];
  #     }
  #     {
  #       # mac
  #       publicKey = "TODO";
  #       allowedIPs = [ "10.100.0.3/32" ];
  #     }
  #   ];
  # };

  # --- Ollama (CPU-only ARM, code RAG workload) ---
  services.ollama = {
    enable = true;
    package = pkgs.ollama; # CPU-only, no CUDA/ROCm — no GPU on Oracle ARM
    host = "0.0.0.0"; # accessible via WireGuard
    port = 11434;
    loadModels = [
      "qwen3-embedding:8b" # code embeddings — #1 MTEB-Code, 4.7GB
      "qwen2.5-coder:14b" # code descriptions/analysis, 9GB
    ];
    environmentVariables = {
      # Keep embedding model loaded — primary workload
      OLLAMA_KEEP_ALIVE = "-1";
    };
  };

  # --- Qdrant (vector database for code RAG) ---
  services.qdrant = {
    enable = true;
    settings = {
      service = {
        host = "0.0.0.0"; # accessible via WireGuard
        http_port = 6333;
        grpc_port = 6334;
      };
      storage = {
        # Payloads on disk — saves RAM
        on_disk_payload = true;
        performance = {
          # All 4 cores available for search
          max_search_threads = 4;
          # 1 core for background indexation
          optimizer_cpu_budget = 1;
        };
      };
      telemetry_disabled = true;
    };
  };

  # --- Playwright MCP (native SSE transport, headless Chromium) ---
  # Runs as a systemd service, accessible via WireGuard on port 8002
  systemd.services.playwright-mcp = {
    description = "Playwright MCP Server (headless)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.bash ];
    environment = {
      HOME = "/var/lib/playwright-mcp";
      NODE_PATH = "${pkgs.nodejs_22}/lib/node_modules";
    };
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = "playwright-mcp";
      ExecStart = "${pkgs.nodejs_22}/bin/npx -y @playwright/mcp@latest --port 8002 --headless --host 0.0.0.0";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # --- Supergateway: expose stdio MCPs as SSE over the network ---

  # memory (local-rag) on port 8001
  systemd.services.mcp-memory = {
    description = "MCP Memory (local-rag) via supergateway";
    after = [
      "network.target"
      "ollama.service"
      "qdrant.service"
    ];
    wants = [
      "ollama.service"
      "qdrant.service"
    ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.bash ];
    environment = {
      HOME = "/var/lib/mcp-memory";
    };
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = "mcp-memory";
      ExecStart =
        let
          configFile = pkgs.writeText "local-rag-config.json" (
            builtins.toJSON {
              "qdrant-url" = "http://localhost:6333";
              "embed-provider" = "ollama";
              "embed-model" = "qwen3-embedding:8b";
              "ollama-url" = "http://localhost:11434";
              "generate-descriptions" = true;
              "llm-provider" = "ollama";
              "llm-model" = "qwen2.5-coder:14b";
            }
          );
        in
        ''
          ${pkgs.nodejs_22}/bin/npx -y supergateway \
            --stdio "${pkgs.nodejs_22}/bin/npx -y @13w/local-rag serve --config ${configFile}" \
            --port 8001
        '';
      Restart = "on-failure";
      RestartSec = 10;
    };
  };

  # fetch on port 8003
  systemd.services.mcp-fetch = {
    description = "MCP Fetch via supergateway";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.bash ];
    environment = {
      HOME = "/var/lib/mcp-fetch";
    };
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = "mcp-fetch";
      ExecStart =
        let
          fetchScript = pkgs.writeShellScript "mcp-fetch" ''
            unset PYTHONPATH
            exec ${pkgs.uv}/bin/uvx mcp-fetch "$@"
          '';
        in
        ''
          ${pkgs.nodejs_22}/bin/npx -y supergateway \
            --stdio "${fetchScript}" \
            --port 8003
        '';
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # context7 on port 8004
  systemd.services.mcp-context7 = {
    description = "MCP Context7 via supergateway";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.bash ];
    environment = {
      HOME = "/var/lib/mcp-context7";
    };
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = "mcp-context7";
      ExecStart = ''
        ${pkgs.nodejs_22}/bin/npx -y supergateway \
          --stdio "${pkgs.nodejs_22}/bin/npx -y @upstash/context7-mcp" \
          --port 8004
      '';
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # context (neuledge) on port 8005
  systemd.services.mcp-context = {
    description = "MCP Context (neuledge) via supergateway";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.bash ];
    environment = {
      HOME = "/var/lib/mcp-context";
    };
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = "mcp-context";
      ExecStart = ''
        ${pkgs.nodejs_22}/bin/npx -y supergateway \
          --stdio "${pkgs.nodejs_22}/bin/npx -y @neuledge/context serve" \
          --port 8005
      '';
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
  ];

  # --- Headless server: no desktop ---
  # No GNOME, no Hyprland, no sound, no printing
}
