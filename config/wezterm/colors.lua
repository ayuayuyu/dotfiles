-- ~/.config/wezterm/colors.lua
local M = {}

-- 共通カラーパレット
M.C = {
  bg       = '#0f1419', -- 深海のような濃い紺黒
  fg       = '#e6e8eb', -- 読みやすい白系
  neon     = '#00d4ff', -- 主役のネオンシアン
  dark_tab = '#1a222e', -- 非アクティブタブ
  bar_bg   = '#0b0f16', -- タブバー背景
  selection_bg = '#004d61',
}

M.colors = {
  foreground = M.C.fg,
  background = M.C.bg,
  
  cursor_bg  = M.C.neon,
  cursor_border = M.C.neon,
  cursor_fg  = '#000000',

  selection_bg = M.C.selection_bg, 
  selection_fg = '#ffffff',

  split = M.C.neon, 

  ansi = {
    '#0f1419', '#ff5c57', '#5af78e', '#f3f99d', 
    '#57c7ff', '#ff6ac1', '#00d4ff', '#e6e8eb',
  },
  brights = {
    '#686868', '#ff5c57', '#5af78e', '#f3f99d', 
    '#57c7ff', '#ff6ac1', '#00d4ff', '#ffffff',
  },

  tab_bar = {
    background = M.C.bar_bg,
  },
}

return M
