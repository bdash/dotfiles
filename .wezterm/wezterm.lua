local wezterm = require 'wezterm'
local act = wezterm.action
local appearance = require 'appearance'
local ssh_domains = require 'ssh_domains'
local tmux = require 'tmux'

local config = wezterm.config_builder()

-- New windows and tabs start in home directory
config.default_cwd = wezterm.home_dir
config.selection_word_boundary = ' \t\n{}[]()"\'`:'

config.scrollback_lines = 100000

-- Simple key bindings (non-leader)
local keys = {
  { key = 'k', mods = 'CMD', action = act.ClearScrollback 'ScrollbackAndViewport' },
  { key = ',', mods = 'SUPER', action = act.SpawnCommandInNewWindow {
    cwd = wezterm.home_dir,
    args = { '/opt/homebrew/bin/nvim', wezterm.config_file },
  }},
  { key = 'p', mods = 'CMD', action = act.ActivateCommandPalette },

  -- Override default new tab/window to use home directory
  { key = 't', mods = 'CMD', action = act.SpawnCommandInNewTab { cwd = wezterm.home_dir } },
  { key = 'n', mods = 'CMD', action = act.SpawnCommandInNewWindow { cwd = wezterm.home_dir } },

  -- Send a literal newline for Shift-Return and Opt-Return (for Claude app)
  { key = 'Return', mods = 'SHIFT', action = act.SendString '\n' },
  { key = 'Return', mods = 'OPT', action = act.SendString '\n' },
}

-- Setup modules
appearance.setup(config)
ssh_domains.setup(config)
tmux.setup(config, keys)

config.keys = keys

config.mouse_bindings = {
    -- Disable the default click behavior
    {
      event = { Up = { streak = 1, button = "Left"} },
      mods = "NONE",
      -- TODO: Do I want selecting to implicitly copy?
      action = act.CompleteSelection 'ClipboardAndPrimarySelection',
    },
    -- Cmd-click will open the link under the mouse cursor
    {
        event = { Up = { streak = 1, button = "Left" } },
        mods = "CMD",
        action = act.OpenLinkAtMouseCursor,
    },
    -- Disable the Cmd-click down event to stop programs from seeing it when a URL is clicked
    {
        event = { Down = { streak = 1, button = "Left" } },
        mods = "CMD",
        action = act.Nop,
    },

}

return config

