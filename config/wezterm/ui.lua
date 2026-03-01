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
	window_padding = {
		left = 8,
		right = 8,
		top = 4,
		bottom = 4,
	},

	-- カーソルブリンク
	cursor_blink_rate = 500,
	cursor_blink_ease_in = "EaseIn",
	cursor_blink_ease_out = "EaseOut",

	-- スクロールバック・アニメーション
	scrollback_lines = 10000,
	animation_fps = 60,

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
