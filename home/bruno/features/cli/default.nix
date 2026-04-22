{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./zsh.nix
    ./starship.nix
    ./fzf.nix
    ./ssh.nix
  ];

  home.packages =
    with pkgs;
    [
      unzip
      _7zz
      unrar
      tldr
      pfetch
      ncdu
      wget

      # Nix Tools
      nixd # Nix LSP
      nixfmt # Nix formatter (official RFC 166 style)
      nvd # Nix version manager
      nix-diff # Differ, more detailed
      nix-output-monitor # Monitor nix builds
      nh # Nice wrapper for NixOS and Home Manager
    ]
    ++ lib.optionals stdenv.isLinux [
      wl-clipboard
    ];

  programs = {
    bash.enable = true;
    command-not-found.enable = false;
    nix-index.enable = true;
    nix-index.symlinkToCacheHome = true;
    htop.enable = true;
    btop.enable = true;
    bottom.enable = true;
    ripgrep.enable = true; # Better grep
    zoxide.enable = true; # Better cd
    navi.enable = true;
    jq.enable = true;
    fastfetch = {
      enable = true;
      settings = {
        logo = {
          padding = {
            right = 2;
          };
        };
        display = {
          separator = "  ";
          key.width = 17;
          color = {
            keys = "blue";
          };
        };
        modules = [
          "title"
          "separator"
          {
            type = "os";
            key = "  OS";
          }
          {
            type = "kernel";
            key = "  Kernel";
          }
          {
            type = "host";
            key = "󰌢 Host";
          }
          {
            type = "uptime";
            key = "  Uptime";
          }
          {
            type = "packages";
            key = "󰏗 Packages";
          }
          {
            type = "shell";
            key = "  Shell";
          }
          {
            type = "terminal";
            key = "  Terminal";
          }
          {
            type = "de";
            key = "  DE";
          }
          "break"
          {
            type = "cpu";
            key = "  CPU";
          }
          {
            type = "gpu";
            key = "󰍛 GPU";
          }
          {
            type = "memory";
            key = "  RAM";
          }
          {
            type = "swap";
            key = "󰓡 Swap";
          }
          {
            type = "disk";
            key = "  Disk (/)";
            folders = "/";
          }
          {
            type = "disk";
            key = "  Disk (/home)";
            folders = "/home";
          }
          "break"
          {
            type = "display";
            key = "󰍹 Display";
          }
          {
            type = "battery";
            key = "  Battery";
          }
          {
            type = "localip";
            key = "󰈀 IP";
          }
          "break"
          {
            type = "command";
            key = "  Docker";
            text = "docker info --format '{{.ContainersRunning}} running / {{.Containers}} total' 2>/dev/null || echo 'not running'";
          }
          {
            type = "command";
            key = "  Ollama";
            text = "curl -sf http://localhost:11434/api/tags 2>/dev/null | jq -r '[.models[].name] | length | tostring + \" models loaded\"' 2>/dev/null || echo 'not running'";
          }
          {
            type = "command";
            key = "󰍛 GPU Driver";
            text = "cat /proc/driver/nvidia/version 2>/dev/null | head -1 | grep -oP '\\d+\\.\\d+' | head -1 || echo 'N/A'";
          }
          "break"
          "colors"
        ];
      };
    };
  };

  programs.pay-respects = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
    };
  };

  programs.micro = {
    enable = true;
    settings = {
      autosu = true;
      tabstospaces = true;
    };
  };

  # Better ls
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    icons = "always";
    colors = "always";
    git = true;
    extraOptions = [
      "--group-directories-first"
    ];
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
    silent = true;
    config.global = {
      hide_env_diff = true;
    };
  };
}
