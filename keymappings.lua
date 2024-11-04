local wezterm = require("wezterm")
local act = wezterm.action
local module = {}

function module.apply_to_config(config)
  -- timeout_milliseconds defaults to 1000 and can be omitted
  config.leader = { key = "w", mods = "ALT", timeout_milliseconds = 3000 }

  config.keys = {
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

    -- Zoom pane (make it fullscreen)
    { key = "f", mods = "ALT", action = act.TogglePaneZoomState },
    -- Close pane and terminate the terminal session.
    { key = "e", mods = "ALT", action = act.CloseCurrentPane({ confirm = true }) },

    -- Split pane vertically, set the size to 0.4 (40%), and place it to the right
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
          direction = "Bottom", -- Split to the bottom
          size = 0.3, -- Set the size to 30%
        })
      end),
    },

    -- Toggle other panes or split pane vertically if there is only one pane
    {
      key = "t",
      mods = "ALT",
      action = wezterm.action_callback(function(_, pane)
        local tab = pane:tab()
        local panes = tab:panes_with_info()
        -- If there is only one pane, split it vertically
        if #panes == 1 then
          pane:split({
            direction = "Right", -- Split to the right
            size = 0.33, -- Set the size to 33%
          })
          -- If the first pane is zoomed, deactivate zoom and focus on the second pane
        elseif panes[1].is_zoomed then
          tab:set_zoomed(false) -- Deactivate zoom
          panes[2].pane:activate() -- Focus on the second pane
        -- If the first pane is not zoomed, focus on it and zoom it (make it fullscreen)
        elseif not panes[1].is_zoomed then
          panes[1].pane:activate() -- Focus on the first pane
          tab:set_zoomed(true) -- Zoom the first pane
        end
      end),
    },

    -- Show Debug overlay
    { key = "d", mods = "LEADER", action = act.ShowDebugOverlay },

    -- SWITCH PANES

    -- Switch to the pane above
    { key = "k", mods = "CTRL", action = act.ActivatePaneDirection("Up") },
    -- Switch to the pane below
    { key = "j", mods = "CTRL", action = act.ActivatePaneDirection("Down") },
    -- Switch to the pane on the left
    { key = "h", mods = "CTRL", action = act.ActivatePaneDirection("Left") },
    -- Switch to the pane on the right
    { key = "l", mods = "CTRL", action = act.ActivatePaneDirection("Right") },

    -- RESIZE PANES

    -- Resize the pane upwards
    { key = "k", mods = "OPT", action = act.AdjustPaneSize({ "Up", 1 }) },
    -- Resize the pane downwards
    { key = "j", mods = "OPT", action = act.AdjustPaneSize({ "Down", 1 }) },
    -- Resize the pane to the left
    { key = "h", mods = "OPT", action = act.AdjustPaneSize({ "Left", 1 }) },
    -- Resize the pane to the right
    { key = "l", mods = "OPT", action = act.AdjustPaneSize({ "Right", 1 }) },

    -- Activate command palette
    { key = ":", mods = "LEADER", action = act.ActivateCommandPalette },

    -- MANIPULATING TABS

    -- Switch to the next tab
    { key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
    -- Switch to the previous tab
    { key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },

    -- Create a new tab
    { key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },

    -- Rename current tab
    {
      key = "r",
      mods = "LEADER",
      action = act.PromptInputLine({
        description = "Enter the tab title:",
        action = wezterm.action_callback(function(window, _, line)
          if line then
            window:active_tab():set_title(line)
          end
        end),
      }),
    },

    -- Create a new tab in the window that contains pane, and move pane into that tab
    {
      key = "!",
      mods = "LEADER",
      action = wezterm.action_callback(function(_, pane)
        pane:move_to_new_tab()
      end),
    },
  }
end

return module
