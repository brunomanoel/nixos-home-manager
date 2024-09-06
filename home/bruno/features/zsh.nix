{ config, pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
    };
    syntaxHighlighting = {
      enable = true;
      # package = pkgs.zsh-fast-syntax-highlighting;
    };
    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
      ignorePatterns = [
        # "sudo *"
        # "cd *"
        "ls *"
        "ll *"
        "l *"
        ".."
      ];
    };
    initExtra = ''
      bindkey '^f' autosuggest-accept
      bindkey '^[[A' history-search-backward
      bindkey '^[[B' history-search-forward

      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

      fastfetch
    '';
    dirHashes = {
      docs  = "$HOME/Documents";
      vids  = "$HOME/Videos";
      dl    = "$HOME/Downloads";
      ws    = "$HOME/workspaces";
    };
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
      {
        name = "zsh-interactive-cd";
        file = "zsh-interactive-cd.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "mrjohannchang";
          repo = "zsh-interactive-cd";
          rev = "e7d4802aa526ec069dafec6709549f4344ce9d4a";
          hash = "sha256-j23Ew18o7i/7dLlrTu0/54+6mbY8srsptfrDP/9BI/Q=";
        };
      }
      {
        name = "fzf-git";
        file = "fzf-git.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "junegunn";
          repo = "fzf-git.sh";
          rev = "6a5d4a923b86908abd9545c8646ae5dd44dff607";
          hash = "sha256-Hn28aoXBKE63hNbKfIKdXqhjVf8meBdoE2no5iv0fBQ=";
        };
      }
    ];
    shellAliases = {
      switch = "sudo nixos-rebuild switch --flake ~/Documents/NixOS/#predabook";
      boot = "sudo nixos-rebuild boot --flake ~/Documents/NixOS/#predabook";
      ".." = "cd ..";
      g = "git";
      gst = "git status";
      ga = "git add -p";
      gcm = "git checkout main";
      gcd = "git checkout develop";
      gcmsg = "git commit -m";
      gpush = "git push";
      gpull = "git pull";
      gl = "git log --oneline --decorate --graph";
      diff = "git diff";
      cat = "bat";
      cd = "z";
      ls = "eza";
    };
  };
}
