{
  config,
  pkgs,
  lib,
  ...
}:
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
    initContent = ''
      bindkey '^f' autosuggest-accept
      bindkey '^p' history-search-backward
      bindkey '^n' history-search-forward

      # case-insensitive completion
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

      # disable sort when completing `git checkout`
      zstyle ':completion:*:git-checkout:*' sort false
      # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
      zstyle ':completion:*' menu no
      # preview directory's content with eza when completing cd
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    '';
    loginExtra = ''
      fastfetch
    '';
    dirHashes = {
      docs = "$HOME/Documents";
      vids = "$HOME/Videos";
      dl = "$HOME/Downloads";
      ws = "$HOME/workspaces";
    };
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
        src = pkgs.zsh-nix-shell;
      }
      {
        name = "zsh-you-should-use";
        file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
        src = pkgs.zsh-you-should-use;
      }
      {
        name = "zsh-forgit";
        file = "share/zsh/zsh-forgit/forgit.plugin.zsh";
        src = pkgs.zsh-forgit;
      }
      {
        name = "fzf-tab";
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
        src = pkgs.zsh-fzf-tab;
      }
    ];
    shellAliases = {
      ".." = "cd ..";
      g = "git";
      gst = "git status";
      gap = "git add -p";
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
