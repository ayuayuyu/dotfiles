local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end


config.colors = {
  split = '#FFD54F', -- 通常時の分割線の色
}

-- theme config
config.color_scheme = 'MaterialDesignColors'
config.window_background_opacity = 0.85

-- -- font config
config.font = wezterm.font("Hack Nerd Font Propo", {weight="Medium", stretch="Normal", style="Normal"})
config.font_rules = {
  {
    italic = true,
    font = wezterm.font_with_fallback {
      { family = "Hack Nerd Font Propo", weight="Medium", stretch="Normal", style="Normal"}
    },
  },
  {
    intensity = "Bold",
    font = wezterm.font_with_fallback {
      { family = "Hack Nerd Font Propo", weight="Medium", stretch="Normal", style="Normal"}
    },
  },
  {
    intensity = "Half",
    font = wezterm.font_with_fallback {
      { family = "Hack Nerd Font Propo", weight="Medium", stretch="Normal", style="Normal"}
    },
  },
}
config.font_size = 14


-- key config
local act = wezterm.action
config.keys = {
  {
    key = 'd',
    mods = 'CMD',
    -- 横に分割 (左右に並べる)
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    -- 縦に分割 (上下に並べる)
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },

  -- 既存のキー設定
  {
    key = "LeftArrow",
    mods = "CMD",
    action = act.SendKey {
      key = "b",
      mods = "META",
    },
  },
  {
    key = "RightArrow",
    mods = "CMD",
    action = act.SendKey {
      key = "f",
      mods = "META",
    },
  },
  {
    key = "Backspace",
    mods = "CMD",
    action = act.SendKey {
      key = "w",
      mods = "CTRL",
    },
  },
  {
    key = "LeftArrow",
    mods = "CTRL",
    action = act.SendKey {
      key = "b",
      mods = "META",
    },
  },
  {
    key = "RightArrow",
    mods = "CTRL",
    action = act.SendKey {
      key = "f",
      mods = "META",
    },
  },
  {
    key = "Backspace",
    mods = "CTRL",
    action = act.SendKey {
      key = "w",
      mods = "CTRL",
    },
  },
  {
    key = 'f',
    mods = 'SHIFT|META',
    action = wezterm.action.ToggleFullScreen,
  },
  {
    key = 'w',
    mods = 'CTRL',
    action = wezterm.action.CloseCurrentTab { confirm = false },
  },
}

-- always open window in full screen
local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():toggle_fullscreen()
end)


-- tabbar config
config.hide_tab_bar_if_only_one_tab = true

-- bell config
config.audible_bell = "Disabled"

return config