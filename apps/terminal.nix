{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
    tree
  ];

  programs = {
	htop.enable = true;
	command-not-found.enable = true;
	btop.enable = true;
	bat.enable = true;
	ripgrep.enable = true;
  };

  programs.ssh = {
	enable = true;
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    # defaultKeymap = "emacs";
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

  programs.thefuck = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    fileWidgetOptions = [
      "--preview 'head {}'"
    ];
    fileWidgetCommand = "fd --type f";
    changeDirWidgetOptions = [
      "--preview 'tree -C {} | head -200'"
    ];
  };

  programs.starship = {
  	enable = true;
  	enableZshIntegration = true;
  	enableBashIntegration = true;
    settings = {
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$package"

        "$fill"
        "$cmd_duration $jobs"
        "$nodejs"
        "$bun"
        "$java"
        "$go"
        "$python"
        "$rust"
        "$elixir"
        "$time"
        "$line_break"
        "$container"
        "$character"
      ];
      right_format = lib.concatStrings [
        "[$git_metrics]($style)"
        "[$git_commit]($style)"
        "[$git_state]($style)"
      ];
      fill = {
        symbol = " ";
      };
      directory = {
        truncation_length = 8;
        truncation_symbol = "…/";
        read_only = " 󰌾";
        style = "bold lavender";
      };
      directory.substitutions = {
        "Documents" = "Documents 󰈙 ";
        "Downloads" = "Downloads  ";
        "Music" = "Music  ";
        "Pictures" = "Pictures  ";
      };
      # scan_timeout = 10;
    };
  };

  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.fd = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 0.8;
      font.size = 16.0;
      # font.normal.family = 'Fira Code';
    };
  };

  programs.tmux = {
  	enable = true;
  	baseIndex = 1;
  	clock24 = true;
  	customPaneNavigationAndResize = true;
  	mouse = true;
  	# keyMode = "vi";
  	sensibleOnTop = true;
  	plugins = with pkgs.tmuxPlugins; [
  	  catppuccin
  	  {
  	    plugin = resurrect;
  	    # extraConfig = "set -g @resurrect-strategy-nvim 'session'";
  	  }
  	  {
  	    plugin = continuum;
  	    extraConfig = ''
  	      set -g @continuum-restore 'on'
  	      set -g @continuum-save-interval '60' # minutes
  	    '';
      }
      vim-tmux-navigator
      yank
      tmux-thumbs
      tmux-fzf
      pain-control
      better-mouse-mode
  	];
  	extraConfig = ''
  	  bind-key -n M-H previous-window
  	  bind-key -n M-L next-window
  	'';
  };
}
