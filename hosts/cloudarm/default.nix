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

    ../common/users/bruno
    ../common/global
  ];

  system.stateVersion = "24.11";

  # --- Boot ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  # Mainline kernel — best aarch64 support (zen/xanmod are x86-focused)
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Oracle Cloud ARM needs predictable interface names disabled
  boot.kernelParams = [ "net.ifnames=0" ];

  # --- Memory & I/O tuning ---
  boot.kernel.sysctl = {
    # zram-aware swappiness (kernel 6.1+ supports >100 with zram)
    "vm.swappiness" = 180;
    "vm.vfs_cache_pressure" = 50;
    # Frequent flush — Oracle block storage is slow (20 VPU max)
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
  };

  # zram swap — no physical swap on cloud, block storage is the bottleneck
  zramSwap = {
    enable = true;
    memoryPercent = 50; # 12GB compressed
  };

  # --- Networking ---
  networking.hostName = "cloudarm";
  networking.useDHCP = true; # Oracle Cloud assigns IP via DHCP

  # Firewall: only SSH + WireGuard exposed publicly
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [
      51820 # WireGuard
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

  users.users.bruno.openssh.authorizedKeys.keys = [
    # TODO: Add SSH public keys
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
      # Embedding workload: many parallel small requests
      OLLAMA_NUM_PARALLEL = "8";
      # Keep models loaded — they're the primary workload
      OLLAMA_KEEP_ALIVE = "-1";
      # Up to 4 models in memory (embedding + coder + headroom)
      OLLAMA_MAX_LOADED_MODELS = "4";
      # Flash attention reduces memory per inference
      OLLAMA_FLASH_ATTENTION = "1";
      # KV cache quantization — saves ~40% memory with minimal quality loss
      OLLAMA_KV_CACHE_TYPE = "q8_0";
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
              "embed-dim" = 1024;
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
    environment = {
      HOME = "/var/lib/mcp-fetch";
    };
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = "mcp-fetch";
      ExecStart = ''
        ${pkgs.nodejs_22}/bin/npx -y supergateway \
          --stdio "${pkgs.python3}/bin/python3 -m uvx mcp-fetch" \
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
