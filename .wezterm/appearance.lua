local wezterm = require 'wezterm'

local M = {}

-- Tab bar separators - using rounded style
local TAB_LEFT_SEP = wezterm.nerdfonts.ple_left_half_circle_thick
local TAB_RIGHT_SEP = wezterm.nerdfonts.ple_right_half_circle_thick

-- Helper function to clean up tab titles
local function clean_tab_title(title)
  -- Remove username@hostname prefix if present
  title = title:gsub("^[^:]+:", "")

  -- Smart path handling
  if title:match("^~/Source/") then
    -- If under ~/Source, show path relative to it
    return title:gsub("^~/Source/", "")
  elseif title:match("^~/") or title:match("^/") then
    -- Otherwise get the last two directory components
    return title:match("([^/]+/[^/]+)/?$") or title:match("([^/]+)/?$") or title
  end

  return title
end

function M.setup(config)
  -- Colors
  config.color_scheme = 'Classic Dark (base16)'
  config.window_background_opacity = 0.95
  config.macos_window_background_blur = 10
  config.inactive_pane_hsb = {
    saturation = 0.8,
    brightness = 0.7,
  }

  -- Gotta be able to read things
  config.font_size = 13.5

  -- Hide most window decorations, but keep a drop shadow
  -- so adjacent windows don't blend together
  config.window_decorations = "RESIZE | MACOS_FORCE_ENABLE_SHADOW"
  config.hide_tab_bar_if_only_one_tab = true
  config.enable_scroll_bar = true

  -- Shrink the top / bottom padding so we can fit an extra row
  config.window_padding = {
    top = "0.2cell",
    bottom = "0.2cell",
  }

  -- Get the actual background color from the color scheme
  local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]

  -- Tab bar configuration
  config.use_fancy_tab_bar = false
  config.tab_max_width = 32
  config.colors = {
    tab_bar = {
      -- Use the same background as the terminal
      background = scheme.background,
    },
  }

  -- Custom tab formatting
  wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local blue = wezterm.color.parse(scheme.ansi[5])
    local gray = wezterm.color.parse(scheme.ansi[8])
    local white = wezterm.color.parse(scheme.foreground)

    -- Check if the active pane is zoomed
    local is_zoomed = tab.active_pane and tab.active_pane.is_zoomed

    -- Use red instead of blue when zoomed
    local tab_color = is_zoomed and wezterm.color.parse(scheme.ansi[2]) or blue  -- ansi[2] is red

    -- Set colors based on tab state
    local background, foreground
    local intensity = 'Normal'
    if tab.is_active then
      background = tostring(tab_color:darken(0.5))
      foreground = scheme.foreground
      intensity = 'Bold'
    elseif hover then
      background = tostring(tab_color:darken(0.6))
      foreground = tostring(white:darken(0.2))
    else
      background = tostring(tab_color:darken(0.7))
      foreground = tostring(gray:darken(0.2))
    end

    -- Get tab index (1-based for display)
    local tab_index = tab.tab_index + 1

    local title = clean_tab_title(tab.active_pane.title)
    title = wezterm.truncate_right(title, max_width - 5)

    return {
      { Background = { Color = scheme.background } },
      { Foreground = { Color = background } },
      { Text = TAB_LEFT_SEP },
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Attribute = { Intensity = intensity } },
      { Text = ' ' .. tostring(tab_index) .. ' ' },
      { Foreground = { Color = scheme.background } },
      { Text = '│' },
      { Foreground = { Color = foreground } },
      { Text = ' ' .. title .. ' ' },
      { Background = { Color = scheme.background } },
      { Foreground = { Color = background } },
      { Text = TAB_RIGHT_SEP },
    }
  end)

  -- Add user@host info to the right side of tab bar
  wezterm.on('update-status', function(window, pane)
    local cwd_uri = pane:get_current_working_dir()
    local hostname = wezterm.hostname()
    local username = os.getenv("USER") or ""

    if cwd_uri and cwd_uri.host then
      hostname = cwd_uri.host
    end

    -- Strip domain portions (everything after first dot)
    hostname = hostname:match("^([^.]+)") or hostname

    -- Get username from user vars if available
    local user_vars = pane:get_user_vars()
    if user_vars.WEZTERM_USER then
      username = user_vars.WEZTERM_USER
    end

    window:set_right_status(wezterm.format {
      { Foreground = { AnsiColor = 'Grey' } },
      { Text = ' ' .. username .. '@' .. hostname .. ' ' },
    })
  end)
end

return M
