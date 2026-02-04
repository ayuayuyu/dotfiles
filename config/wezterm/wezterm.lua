-- ~/.config/wezterm/wezterm.lua
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local colors_module = require 'colors'
local ui = require 'ui'
local keys = require 'keys'
local bar = require 'bar' 

-- 設定マージ
local function merge_config(src)
  for k, v in pairs(src) do
    config[k] = v
  end
end

config.colors = colors_module.colors

merge_config(ui)
merge_config(keys)
-- barの設定を最後にマージする（これでbarの設定が優先されるはず）
merge_config(bar.config) 

-- ★ここが重要：念には念を入れて強制的に設定する★
-- これで変わらなければ、コードの記述ミスではなく環境の問題です
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false

wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():toggle_fullscreen()
end)

return config