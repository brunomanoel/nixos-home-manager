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
    ./lpass.nix
    ../dev/neovim
  ];

  home.packages =
    with pkgs;
    [
      unzip
      tldr
      fastfetch
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

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local act = wezterm.action
      local config = wezterm.config_builder()

      -- Appearance
      config.font = wezterm.font('FiraCode Nerd Font')
      config.font_size = 16.0
      config.window_background_opacity = 0.8
      config.color_scheme = 'Catppuccin Mocha'

      -- Tabs (like tmux base-index = 1)
      config.tab_bar_at_bottom = false
      config.use_fancy_tab_bar = false

      -- Mouse (like tmux mouse = true)
      config.mouse_bindings = {
        {
          event = { Up = { streak = 1, button = 'Left' } },
          mods = 'NONE',
          action = act.CompleteSelection 'ClipboardAndPrimarySelection',
        },
      }

      -- Leader key: Ctrl+A (like tmux prefix)
      config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

      config.keys = {
        -- Pass Ctrl+A through when pressed twice
        { key = 'a', mods = 'LEADER|CTRL', action = act.SendKey { key = 'a', mods = 'CTRL' } },

        -- Splits (like pain-control: prefix + | and prefix + -)
        { key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
        { key = '-', mods = 'LEADER',       action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

        -- Pane navigation with Ctrl+h/j/k/l (like vim-tmux-navigator)
        { key = 'h', mods = 'CTRL', action = act.ActivatePaneDirection 'Left' },
        { key = 'j', mods = 'CTRL', action = act.ActivatePaneDirection 'Down' },
        { key = 'k', mods = 'CTRL', action = act.ActivatePaneDirection 'Up' },
        { key = 'l', mods = 'CTRL', action = act.ActivatePaneDirection 'Right' },

        -- Pane navigation with Ctrl+Alt+Arrow keys
        { key = 'LeftArrow',  mods = 'CTRL|ALT', action = act.ActivatePaneDirection 'Left' },
        { key = 'DownArrow',  mods = 'CTRL|ALT', action = act.ActivatePaneDirection 'Down' },
        { key = 'UpArrow',    mods = 'CTRL|ALT', action = act.ActivatePaneDirection 'Up' },
        { key = 'RightArrow', mods = 'CTRL|ALT', action = act.ActivatePaneDirection 'Right' },

        -- Pane resize with Leader + H/J/K/L (like pain-control)
        { key = 'H', mods = 'LEADER', action = act.AdjustPaneSize { 'Left', 5 } },
        { key = 'J', mods = 'LEADER', action = act.AdjustPaneSize { 'Down', 5 } },
        { key = 'K', mods = 'LEADER', action = act.AdjustPaneSize { 'Up', 5 } },
        { key = 'L', mods = 'LEADER', action = act.AdjustPaneSize { 'Right', 5 } },

        -- Tab navigation with Alt+H/L (like tmux bind-key -n M-H/M-L)
        { key = 'H', mods = 'ALT', action = act.ActivateTabRelative(-1) },
        { key = 'L', mods = 'ALT', action = act.ActivateTabRelative(1) },

        -- New tab (like tmux new-window)
        { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },

        -- Close pane (like tmux kill-pane)
        { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },

        -- Zoom pane (like tmux zoom)
        { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },

        -- Tab switching with Leader + number (like tmux select-window)
        { key = '1', mods = 'LEADER', action = act.ActivateTab(0) },
        { key = '2', mods = 'LEADER', action = act.ActivateTab(1) },
        { key = '3', mods = 'LEADER', action = act.ActivateTab(2) },
        { key = '4', mods = 'LEADER', action = act.ActivateTab(3) },
        { key = '5', mods = 'LEADER', action = act.ActivateTab(4) },
        { key = '6', mods = 'LEADER', action = act.ActivateTab(5) },
        { key = '7', mods = 'LEADER', action = act.ActivateTab(6) },
        { key = '8', mods = 'LEADER', action = act.ActivateTab(7) },
        { key = '9', mods = 'LEADER', action = act.ActivateTab(8) },
      }

      return config
    '';
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
