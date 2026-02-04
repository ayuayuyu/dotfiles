-- ~/.config/wezterm/keys.lua
local wezterm = require 'wezterm'
local act = wezterm.action

return {
  keys = {
    { key = 'd', mods = 'CMD', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    
    -- カーソル移動のEmacsライクなバインディング
    { key = "LeftArrow", mods = "CMD", action = act.SendKey { key = "a", mods = "CTRL" } },
    { key = "RightArrow", mods = "CMD", action = act.SendKey { key = "e", mods = "CTRL" } },
    { key = "LeftArrow", mods = "ALT", action = act.SendKey { key = "b", mods = "META" } },
    { key = "RightArrow", mods = "ALT", action = act.SendKey { key = "f", mods = "META" } },
    { key = "Backspace", mods = "CMD", action = act.SendKey { key = "u", mods = "CTRL" } },
    { key = "Backspace", mods = "ALT", action = act.SendKey { key = "w", mods = "CTRL" } },

    { key = 'f', mods = 'SHIFT|META', action = act.ToggleFullScreen },
    { key = 'w', mods = 'CMD', action = act.CloseCurrentTab { confirm = false } },
    { key = 'w', mods = 'ALT', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  }
}
