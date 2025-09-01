local wezterm = require 'wezterm'
local act = wezterm.action
local appearance = require 'appearance'
local ssh_domains = require 'ssh_domains'
local tmux = require 'tmux'

local config = wezterm.config_builder()

-- New windows and tabs start in home directory
config.default_cwd = wezterm.home_dir

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

return config

