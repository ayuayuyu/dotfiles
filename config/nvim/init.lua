-- ~/.config/nvim/init.lua

-- リーダーキーはプラグイン読み込み前に設定する必要があります
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 設定とキーマップを読み込み
require("config.options")
require("config.keymaps")

-- lazy.nvim のブートストラップ（自動インストール）
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- プラグインのセットアップ
-- lua/plugins フォルダ内のファイルを自動的に全て読み込みます
require("lazy").setup("plugins")