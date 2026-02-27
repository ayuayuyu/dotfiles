local wezterm = require("wezterm")

local config = {
	-- フォント設定
	font = wezterm.font("Hack Nerd Font Propo", { weight = "Medium" }),
	font_size = 14.0,
	line_height = 1.15,

	-- ウィンドウ設定
	window_background_opacity = 0.75,
	window_decorations = "RESIZE",
	default_cursor_style = "BlinkingBar",

	-- ビープ音無効化
	audible_bell = "Disabled",

	-- 非アクティブなペインを少し暗くする
	inactive_pane_hsb = {
		saturation = 0.7,
		brightness = 0.6,
	},
}

-- macOS専用: ウィンドウ背景のぼかし効果
if wezterm.target_triple:find("darwin") ~= nil then
	config.macos_window_background_blur = 30
end

return config
