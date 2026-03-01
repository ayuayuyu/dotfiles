local wezterm = require("wezterm")
local config = wezterm.config_builder()

local colors_module = require("colors")
local ui = require("ui")
local keys = require("keys")
local bar = require("bar")

-- 設定マージ
local function merge_config(src)
	for k, v in pairs(src) do
		config[k] = v
	end
end

config.colors = colors_module.colors

merge_config(ui)
merge_config(keys)
merge_config(bar.config)

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():toggle_fullscreen()
end)

return config

