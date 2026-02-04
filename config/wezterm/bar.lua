-- ~/.config/wezterm/bar.lua
local wezterm = require 'wezterm'

-- エラー防止 & 配色定義
local status, loaded_colors = pcall(require, 'colors')

-- ★ここに「水色」を定義します
local MIZUIRO = '#00ced1' -- 明るい水色 (DarkTurquoise)
-- もっと青っぽい水色が好きなら '#00f5ff' (Cyan) などに変えてみてください

local colors = (status and loaded_colors.C) or {
  bar_bg = '#16161e',     -- バー全体の背景（かなり暗い色）
  neon = MIZUIRO,         -- 時計の色もこれに合わせる
  dark_tab = '#565f89',   -- 区切り線の色
}

local M = {}

M.config = {
  use_fancy_tab_bar = false,
  tab_bar_at_bottom = true,
  hide_tab_bar_if_only_one_tab = false,
  tab_max_width = 60, -- タブの幅（広め）
}

-- ---------------------------------------------------------
-- ヘルパー関数
-- ---------------------------------------------------------
local function get_process_icon(process_name)
  local icons = {
    ['docker'] = '', ['docker-compose'] = '', ['nvim'] = '', ['vim'] = '',
    ['vi'] = '', ['ssh'] = '', ['top'] = '', ['htop'] = '',
    ['zsh'] = '', ['bash'] = '', ['node'] = '', ['python'] = '',
    ['git'] = '',
  }
  if not process_name then return '' end
  local name = process_name:match("^%S+")
  if name then name = name:match("([^/]+)$") end
  return icons[name] or ''
end

local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

-- ---------------------------------------------------------
-- イベント登録
-- ---------------------------------------------------------

-- 1. タブのタイトル描画
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  
  -- ★基本の色（非アクティブ時）
  local background = "#1f2335" -- 暗い背景
  local foreground = "#7aa2f7" -- 薄い青文字
  local edge_background = "none"
  
  -- ★アクティブ時の色設定（ここを水色に変更）
  if tab.is_active then
    background = MIZUIRO    -- 背景を水色に
    foreground = "#000000"  -- 文字を黒に（水色の上だと黒が見やすい）
  end
  
  local edge_foreground = background
  local pane = tab.active_pane
  local process_name = pane.title
  
  local icon = get_process_icon(process_name)
  local title_text = tab.tab_title
  if not title_text or #title_text == 0 then
      title_text = pane.title
  end

  -- 表示内容（アイコンとタイトルの間に余裕を持たせる）
  local display_title = string.format("  %s  %s  ", icon, wezterm.truncate_right(title_text, max_width - 8))

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = display_title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

-- 2. ステータスバー（右側）
wezterm.on('update-status', function(window, pane)
  local hostname = wezterm.hostname()
  local date = wezterm.strftime '%H:%M'

  local col_bg = colors.bar_bg
  local col_main = colors.neon     -- ここで定義した水色が使われます
  local col_sec = colors.dark_tab  

  window:set_right_status(wezterm.format {
    -- ホスト名
    { Foreground = { Color = col_sec } },
    { Background = { Color = col_bg } },
    { Text = '' },
    { Background = { Color = col_sec } },
    { Foreground = { Color = col_main } }, -- 文字色を水色に
    { Text = '  ' .. hostname .. ' ' },

    -- 時計
    { Foreground = { Color = col_main } }, -- 背景色を水色に
    { Background = { Color = col_sec } },
    { Text = '' },
    { Background = { Color = col_main } },
    { Foreground = { Color = '#000000' } }, -- 文字色は黒
    { Attribute = { Intensity = 'Bold' } },
    { Text = '  ' .. date .. ' ' },
  })
end)

return M