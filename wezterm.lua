-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

-- Start full screen
wezterm.on("gui-startup", function()
  local tab, pane, window = mux.spawn_window({})
  window:gui_window():toggle_fullscreen()
end)

-- Show the date and time in the tab bar
wezterm.on("update-right-status", function(window)
  local date = wezterm.strftime("%Y-%m-%d %H:%M:%S ")
  window:set_right_status(wezterm.format({
    { Text = date },
  }))
end)

-- change the title of tab to current working directory.
-- ref:
-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html#format-tab-title
-- https://wezfurlong.org/wezterm/config/lua/PaneInformation.html
-- https://wezfurlong.org/wezterm/config/lua/pane/get_current_working_dir.html
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local active_pane = tab.active_pane
  -- cwd is a URL object with file:// as beginning.
  local cwd = active_pane.current_working_dir
  if cwd == nil then
    return
  end
  -- get cwd in string format, https://wezfurlong.org/wezterm/config/lua/wezterm.url/Url.html
  local cwd_str = cwd.file_path
  -- shorten the path by using ~ as $HOME.
  local home_dir = os.getenv("HOME") or "/Users/aw"
  return string.gsub(cwd_str, home_dir, "~")
end)

-- This is where you actually apply your config choices
return {
  -- Apply changes to the configuration without restarting the terminal
  automatically_reload_config = true,

  -- front_end = "WebGpu", -- use WebGPU for rendering

  term = "xterm-256color", -- "xterm-256color", "wezterm"

  -- COLOR SCHEME --
  --
  -- color_scheme = "Nightfly (Gogh)",
  color_scheme = "nightfox",

  -- FONT  SETTINGS --
  --
  font = wezterm.font_with_fallback({ "JetbrainsMono Nerd Font" }, {}),
  font_size = 14.25,
  line_height = 1.2,

  -- KEYBINDINGS --
  --
  -- timeout_milliseconds defaults to 1000 and can be omitted
  leader = { key = "w", mods = "ALT", timeout_milliseconds = 2000 },
  -- Use both Option keys as Meta (Alt) key
  send_composed_key_when_left_alt_is_pressed = false,
  send_composed_key_when_right_alt_is_pressed = false,
  keys = {
    -- Clears the scrollback and viewport, and then sends CTRL-L to ask the shell to redraw its prompt
    {
      key = "k",
      mods = "CMD",
      action = act.Multiple({
        act.ClearScrollback("ScrollbackAndViewport"),
        act.SendKey({ key = "L", mods = "CTRL" }),
      }),
    },

    -- PANE MANAGEMENT --
    --
    -- Zoom pane
    { key = "f", mods = "ALT", action = act.TogglePaneZoomState },
    -- Close pane
    { key = "e", mods = "ALT", action = act.CloseCurrentPane({ confirm = true }) },
    -- Toggle pane
    -- { key = "t", mods = "ALT", action = act.TogglePaneZoomState },
    -- PANE RESIZE --
    --
    -- Move border of the focused pane to the right
    { key = "l", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 1 }) },
    -- Move border of the focused pane to the left
    { key = "h", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Left", 1 }) },
    -- Move border of the focused pane to the top
    { key = "k", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Up", 1 }) },
    -- Move border of the focused pane to the bottom
    { key = "j", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Down", 1 }) },
    -- MOVE FOCUS BETWEEN PANES --
    --
    -- Move focus to the pane right
    { key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
    -- Move focus to the pane left
    { key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
    -- Move focus to the pane top
    { key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
    -- Move focus to the pane bottom
    { key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
    -- TABS --
    --
    -- Switch to the next tab
    { key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
    -- Switch to the previous tab
    { key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
    -- NEW PANE --
    --
    -- Split pane vertically
    {
      key = "v",
      mods = "ALT",
      action = wezterm.action_callback(function(_, pane)
        pane:split({
          direction = "Right",
          size = 0.4,
        })
      end),
    },
    -- Split pane horizontally
    {
      key = "s",
      mods = "ALT",
      action = wezterm.action_callback(function(_, pane)
        pane:split({
          direction = "Bottom",
          size = 0.3,
        })
      end),
    },
    -- Toggle pane or split pane vertically if there is only one pane
    {
      key = "t",
      mods = "ALT",
      action = wezterm.action_callback(function(_, pane)
        local tab = pane:tab()
        local panes = tab:panes_with_info()
        -- If there is only one pane, split it vertically
        if #panes == 1 then
          pane:split({
            direction = "Right",
            size = 0.33,
          })
        -- If there are two panes, toggle between them (zoom)
        elseif not panes[1].is_zoomed then
          -- Activate the first pane and zoom it
          panes[1].pane:activate()
          tab:set_zoomed(true)
        -- If the first pane is zoomed, deactivate zoom
        elseif panes[1].is_zoomed then
          -- Deactivate zoom and activate the second pane
          tab:set_zoomed(false)
          panes[2].pane:activate()
        end
      end),
    },
  },

  -- TAB BAR --
  --
  enable_tab_bar = true,
  use_fancy_tab_bar = true,
  hide_tab_bar_if_only_one_tab = true,
  tab_bar_at_bottom = false,
  tab_max_width = 30,
  switch_to_last_active_tab_when_closing_tab = true,

  -- WINDOW SETTINGS --
  --
  native_macos_fullscreen_mode = true,
  window_background_opacity = 1.0,
  window_decorations = "RESIZE", -- "TITLE", "TITLE|RESIZE"
  window_padding = {
    left = 15,
    right = 15,
    top = 5,
    bottom = 5,
  },
  window_close_confirmation = "AlwaysPrompt", -- 'NeverPrompt'

  warn_about_missing_glyphs = false,
}
