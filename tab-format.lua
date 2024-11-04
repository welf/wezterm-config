local wezterm = require("wezterm")
local colors = require("colors")
local module = {}

-- change the title of tab to current working directory.
-- ref:
-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html#format-tab-title
-- https://wezfurlong.org/wezterm/config/lua/PaneInformation.html
-- https://wezfurlong.org/wezterm/config/lua/pane/get_current_working_dir.html
local function getTabTitle(tab)
  local title = tab.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end

  local active_pane = tab.active_pane

  -- cwd is a URL object with file:// as beginning.
  local cwd = active_pane.current_working_dir

  local defaultTitle = " " .. wezterm.nerdfonts.oct_file_directory_open_fill .. " " .. tab.active_pane.title .. " "

  if cwd == nil then
    return defaultTitle
  end

  local is_project_dir = false
  local is_work_dir = false

  local home_dir = os.getenv("HOME") or "/Users/aw"

  -- get cwd in string format, https://wezfurlong.org/wezterm/config/lua/wezterm.url/Url.html
  if cwd and cwd.file_path then
    cwd = cwd.file_path

    local project_prefix = home_dir .. "/Dev/"
    local work_prefix = home_dir .. "/Work/"

    is_project_dir = cwd:sub(1, #project_prefix) == project_prefix
    is_work_dir = cwd:sub(1, #work_prefix) == work_prefix

    if is_project_dir then
      -- shorten the path to the project directory
      return cwd:gsub(project_prefix, "") .. " " .. wezterm.nerdfonts.cod_code .. " "
    elseif is_work_dir then
      -- shorten the path to the work directory
      return cwd:gsub(work_prefix, "") .. " " .. wezterm.nerdfonts.cod_code .. " "
    else
      -- shorten the path by using ~ as $HOME.
      return string.gsub(cwd, home_dir, "~") .. " " .. wezterm.nerdfonts.oct_file_directory_open_fill .. " "
    end
  else
    -- Otherwise, use the title from the active pane in that tab
    return defaultTitle
  end
end

function module.apply_to_config(config)
  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local activeTabBackground = colors.colors.blue
    local inactiveTabBackground = colors.colors.dim_blue

    local edgeForeground = "#CCCCCC"
    local activeTabForeground = colors.primary
    local inactiveTabForeground = colors.disabled

    local tabBackground = inactiveTabBackground
    local tabForeground = inactiveTabForeground
    local intensity = "Normal"
    local italic = true

    if tab.is_active then
      tabBackground = activeTabBackground
      tabForeground = activeTabForeground
      intensity = "Bold"
      italic = true
    end

    local title = getTabTitle(tab)

    local edgeLeft = wezterm.nerdfonts.ple_lower_right_triangle
    local edgeRight = wezterm.nerdfonts.ple_upper_left_triangle

    return {
      { Background = { Color = colors.statusBarBackground } },
      { Foreground = { Color = edgeForeground } },
      { Text = edgeLeft },
      { Background = { Color = tabBackground } },
      { Foreground = { Color = edgeForeground } },
      { Text = edgeRight },
      { Background = { Color = tabBackground } },
      { Foreground = { Color = tabForeground } },
      { Attribute = { Intensity = intensity } },
      { Attribute = { Italic = italic } },
      { Text = title },
      { Background = { Color = colors.statusBarBackground } },
      { Foreground = { Color = tabBackground } },
      { Text = edgeRight },
    }
  end)
end

return module
