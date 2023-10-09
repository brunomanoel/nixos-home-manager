{ config, pkgs, ... }:
{
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
    enableCompletion = true;
    enableAutosuggestions = true;
    # enableSyntaxHighlighting = true;
    syntaxHighlighting.enable = true;
    loginExtra = "neofetch";
    initExtra = ''
      bindkey '^f' autosuggest-accept
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
  	enable = true;
  	enableZshIntegration = true;
  };

  programs.dircolors = {
	enable = true;
	enableZshIntegration = true;
  };
  
  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 0.8;
      font.size = 15.0;
      # font.normal.family = 'Fira Code';
    };
  };

  programs.tmux = {
  	enable = true;
  	baseIndex = 1;
  	clock24 = true;
  	customPaneNavigationAndResize = true;
  	mouse = true;
  	keyMode = "vi";
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
