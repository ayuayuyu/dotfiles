-- ~/.config/wezterm/keys.lua
local wezterm = require 'wezterm'
local act = wezterm.action

-- macOS は CMD、Linux/Windows は SUPER を使用
local is_darwin = wezterm.target_triple:find("darwin") ~= nil
local mod       = is_darwin and "CMD"       or "SUPER"
local mod_shift = is_darwin and "CMD|SHIFT" or "SUPER|SHIFT"
local mod_ctrl  = is_darwin and "CTRL|CMD"  or "CTRL|SUPER"

-- ----------------------------------------
-- CopyMode (vim ライクなスクロール/テキスト選択)
-- キー一覧:
--   hjkl      : 移動
--   w / b     : 単語移動
--   0 / $     : 行頭 / 行末
--   gg / G    : 先頭 / 末尾
--   v / V     : ビジュアル選択 / 行選択
--   y         : ヤンク & CopyMode 終了
--   / ?       : 前方 / 後方検索
--   n / N     : 次 / 前の検索結果
--   ESC or q  : CopyMode 終了
-- ----------------------------------------
local copy_mode_keys = {
  -- 移動
  { key = 'h', mods = 'NONE', action = act.CopyMode 'MoveLeft'  },
  { key = 'j', mods = 'NONE', action = act.CopyMode 'MoveDown'  },
  { key = 'k', mods = 'NONE', action = act.CopyMode 'MoveUp'    },
  { key = 'l', mods = 'NONE', action = act.CopyMode 'MoveRight' },

  -- 単語移動
  { key = 'w', mods = 'NONE', action = act.CopyMode 'MoveForwardWord'  },
  { key = 'b', mods = 'NONE', action = act.CopyMode 'MoveBackwardWord' },
  { key = 'e', mods = 'NONE', action = act.CopyMode 'MoveForwardWordEnd' },

  -- 行頭 / 行末
  { key = '0', mods = 'NONE',  action = act.CopyMode 'MoveToStartOfLine'        },
  { key = '$', mods = 'SHIFT', action = act.CopyMode 'MoveToEndOfLineContent'   },

  -- ページ移動
  { key = 'u', mods = 'CTRL', action = act.CopyMode { MoveByPage = -0.5 } },
  { key = 'd', mods = 'CTRL', action = act.CopyMode { MoveByPage =  0.5 } },
  { key = 'b', mods = 'CTRL', action = act.CopyMode { MoveByPage = -1.0 } },
  { key = 'f', mods = 'CTRL', action = act.CopyMode { MoveByPage =  1.0 } },

  -- ファイル先頭 / 末尾
  { key = 'g', mods = 'NONE',  action = act.CopyMode 'MoveToScrollbackTop'    },
  { key = 'G', mods = 'SHIFT', action = act.CopyMode 'MoveToScrollbackBottom' },

  -- ビジュアル選択
  { key = 'v', mods = 'NONE',  action = act.CopyMode { SetSelectionMode = 'Cell' } },
  { key = 'V', mods = 'SHIFT', action = act.CopyMode { SetSelectionMode = 'Line' } },
  { key = 'v', mods = 'CTRL',  action = act.CopyMode { SetSelectionMode = 'Block' } },

  -- ヤンク
  { key = 'y', mods = 'NONE', action = act.Multiple {
    act.CopyTo 'ClipboardAndPrimarySelection',
    act.CopyMode 'Close',
  }},

  -- 検索
  { key = '/',       mods = 'NONE',  action = act.Search { CaseSensitiveString = '' } },
  { key = '?',       mods = 'SHIFT', action = act.Search { CaseSensitiveString = '' } },
  { key = 'n',       mods = 'NONE',  action = act.CopyMode 'NextMatch'     },
  { key = 'N',       mods = 'SHIFT', action = act.CopyMode 'PriorMatch'    },

  -- 終了
  { key = 'q',      mods = 'NONE', action = act.CopyMode 'Close' },
  { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
}

return {
  keys = {
    -- ペイン分割
    { key = 'd', mods = mod,       action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'd', mods = mod_shift, action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },

    -- CopyMode に入る (vim ライクなスクロール/検索)
    { key = '[', mods = mod, action = act.ActivateCopyMode },

    -- カーソル移動 (Emacs ライクなバインディング)
    { key = "LeftArrow",  mods = mod,   action = act.SendKey { key = "a", mods = "CTRL" } },
    { key = "RightArrow", mods = mod,   action = act.SendKey { key = "e", mods = "CTRL" } },
    { key = "LeftArrow",  mods = "ALT", action = act.SendKey { key = "b", mods = "META" } },
    { key = "RightArrow", mods = "ALT", action = act.SendKey { key = "f", mods = "META" } },
    { key = "Backspace",  mods = mod,   action = act.SendKey { key = "u", mods = "CTRL" } },
    { key = "Backspace",  mods = "ALT", action = act.SendKey { key = "w", mods = "CTRL" } },

    -- 画面の最大化/元に戻す
    { key = 'f', mods = mod_ctrl, action = act.ToggleFullScreen },

    { key = 'w', mods = mod,   action = act.CloseCurrentTab { confirm = false } },
    { key = 'w', mods = 'ALT', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  },

  key_tables = {
    copy_mode = copy_mode_keys,
  },
}
