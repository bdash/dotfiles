local wezterm = require 'wezterm'
local act = wezterm.action

local M = {}

local function is_remote(pane)
  local domain = pane:get_domain_name()
  if domain:find('SSH:') then
    return true
  end

  local process_info = pane:get_foreground_process_info()
  if process_info and process_info.name then
    return process_info.name:find('ssh') or
           process_info.name:find('mosh') or
           process_info.name:find('tmux')
  end

  return false
end

local function leader_action(key, local_action)
  return wezterm.action_callback(function(window, pane)
    if is_remote(pane) then
      -- Send Ctrl-o followed by the tmux key
      window:perform_action(act.SendKey { key = 'o', mods = 'CTRL' }, pane)
      window:perform_action(act.SendKey { key = key }, pane)
    else
      window:perform_action(local_action, pane)
    end
  end)
end

-- Helper to add both LEADER and LEADER|CTRL variants
local function leader_key(key, local_action)
  return {
    -- Without CTRL held
    { key = key, mods = 'LEADER', action = leader_action(key, local_action) },
    -- With CTRL held
    { key = key, mods = 'LEADER|CTRL', action = leader_action(key, local_action) }
  }
end

function M.setup(config, keys)
  config.leader = { key = 'o', mods = 'CTRL', timeout_milliseconds = 2000 }

  -- Helper to properly add leader key bindings (works around Lua's table.unpack limitations)
  local function add_leader_keys(key, local_action)
    for _, binding in ipairs(leader_key(key, local_action)) do
      table.insert(keys, binding)
    end
  end

  -- Ctrl-o Ctrl-o sends Ctrl-o to the terminal (escape hatch)
  table.insert(keys, {
    key = 'o',
    mods = 'LEADER|CTRL',
    action = act.SendKey { key = 'o', mods = 'CTRL' }
  })

  -- Splits
  add_leader_keys('-', act.SplitVertical { domain = 'CurrentPaneDomain' })
  add_leader_keys('|', act.SplitHorizontal { domain = 'CurrentPaneDomain' })

  -- Navigation arrows
  add_leader_keys('LeftArrow', act.ActivatePaneDirection 'Left')
  add_leader_keys('RightArrow', act.ActivatePaneDirection 'Right')
  add_leader_keys('UpArrow', act.ActivatePaneDirection 'Up')
  add_leader_keys('DownArrow', act.ActivatePaneDirection 'Down')

  -- Vim-style navigation (hjkl)
  add_leader_keys('h', act.ActivatePaneDirection 'Left')
  add_leader_keys('j', act.ActivatePaneDirection 'Down')
  add_leader_keys('k', act.ActivatePaneDirection 'Up')
  add_leader_keys('l', act.ActivatePaneDirection 'Right')

  -- Tabs (spawn in home directory)
  add_leader_keys('c', act.SpawnCommandInNewTab { cwd = wezterm.home_dir })
  add_leader_keys('n', act.ActivateTabRelative(1))
  add_leader_keys('p', act.ActivateTabRelative(-1))

  -- Zoom
  add_leader_keys('z', act.TogglePaneZoomState)

  -- Add number keys 0-9
  for i = 0, 9 do
    add_leader_keys(tostring(i),
      act.ActivateTab(i == 0 and 9 or i - 1))
  end

  -- Forward other common tmux keys that WezTerm doesn't handle
  -- These will always be sent to tmux when using leader
  local tmux_passthrough = {
    ':', -- command prompt
    'x', -- kill pane
    '&', -- kill window  
    ',', -- rename window
    '.', -- move window
    ';', -- last pane
    '=', -- choose buffer
    '?', -- list keys
    'd', -- detach
    'D', -- detach others
    'f', -- find window
    'i', -- display info
    'q', -- display pane numbers
    's', -- choose session
    't', -- clock
    'w', -- choose window
    '~', -- show messages
    '!', -- break pane
    '"', -- split vertical (alternative)
    '#', -- list buffers
    '$', -- rename session
    '%', -- split horizontal (alternative)
    '\'', -- kill session
    '(', -- switch to previous session
    ')', -- switch to next session
    '*', -- rename session
    '+', -- choose tree
    '[', -- copy mode
    ']', -- paste buffer
    '{', -- swap pane left
    '}', -- swap pane right
    'Space', -- next layout
    'PageUp', -- enter copy mode and scroll up
    'PageDown', -- scroll down in copy mode
  }

  for _, key in ipairs(tmux_passthrough) do
    table.insert(keys, {
      key = key,
      mods = 'LEADER',
      action = act.Multiple {
        act.SendKey { key = 'o', mods = 'CTRL' },
        act.SendKey { key = key },
      }
    })
    -- Also with CTRL held
    table.insert(keys, {
      key = key,
      mods = 'LEADER|CTRL',
      action = act.Multiple {
        act.SendKey { key = 'o', mods = 'CTRL' },
        act.SendKey { key = key },
      }
    })
  end
end

return M

