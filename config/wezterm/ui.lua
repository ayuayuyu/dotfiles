-- ~/.config/wezterm/ui.lua
local wezterm = require 'wezterm'

return {
  -- フォント設定
  font = wezterm.font("Hack Nerd Font Propo", { weight = "Medium" }),
  font_size = 14.0,
  line_height = 1.15,

  -- ウィンドウ設定
  window_background_opacity = 0.90,
  macos_window_background_blur = 30,
  window_decorations = "RESIZE",
  default_cursor_style = 'BlinkingBar',
  
  -- ビープ音無効化
  audible_bell = "Disabled",
  
  -- 非アクティブなペインを少し暗くする
  inactive_pane_hsb = {
    saturation = 0.7,
    brightness = 0.6,
  },
}
