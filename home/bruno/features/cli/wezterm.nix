{ ... }:
{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local act = wezterm.action
      local config = wezterm.config_builder()

      -- Detect whether the active process in the pane is nvim, so we can
      -- forward Ctrl+hjkl to it (unified navigation via smart-splits.nvim).
      local function is_nvim(pane)
        local proc = pane:get_foreground_process_name() or ""
        return proc:match("n?vim$") ~= nil
      end

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

      -- Pane navigation with Ctrl+h/j/k/l via smart-splits integration
      -- (forwards the key to nvim when it's the active process, so splits
      -- and panes share the same nav key)
      { key = 'h', mods = 'CTRL', action = wezterm.action_callback(function(win, pane)
          if is_nvim(pane) then
            win:perform_action(act.SendKey { key = 'h', mods = 'CTRL' }, pane)
          else
            win:perform_action(act.ActivatePaneDirection 'Left', pane)
          end
        end) },
      { key = 'j', mods = 'CTRL', action = wezterm.action_callback(function(win, pane)
          if is_nvim(pane) then
            win:perform_action(act.SendKey { key = 'j', mods = 'CTRL' }, pane)
          else
            win:perform_action(act.ActivatePaneDirection 'Down', pane)
          end
        end) },
      { key = 'k', mods = 'CTRL', action = wezterm.action_callback(function(win, pane)
          if is_nvim(pane) then
            win:perform_action(act.SendKey { key = 'k', mods = 'CTRL' }, pane)
          else
            win:perform_action(act.ActivatePaneDirection 'Up', pane)
          end
        end) },
      { key = 'l', mods = 'CTRL', action = wezterm.action_callback(function(win, pane)
          if is_nvim(pane) then
            win:perform_action(act.SendKey { key = 'l', mods = 'CTRL' }, pane)
          else
            win:perform_action(act.ActivatePaneDirection 'Right', pane)
          end
        end) },

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

      -- Disable kitty keyboard protocol: ctrl+r sends CSI 114;5u instead of
      -- ^R, breaking fzf-history-widget and other traditional zsh bindings.
      config.enable_kitty_keyboard = false

      return config
    '';
  };
}
