{ config, pkgs, lib, ... }:
{
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
