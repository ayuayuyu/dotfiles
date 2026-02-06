-- ~/.config/nvim/init.lua

-- リーダーキーはプラグイン読み込み前に設定する必要があります
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 設定とキーマップを読み込み
require("config.options")
require("config.keymaps")
require("config.lazy")

