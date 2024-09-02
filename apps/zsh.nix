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
          rev = "v0.7.0";
          sha256 = "149zh2rm59blr2q458a5irkfh82y3dwdich60s9670kl3cl5h2m1";
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
    };
  };
}
