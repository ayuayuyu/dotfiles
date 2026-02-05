-- ~/.config/nvim/lua/config/options.lua

-- 基本設定
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.number = true          -- 行番号を表示
vim.opt.cursorline = true      -- 現在の行をハイライト
vim.opt.termguicolors = true   -- True Colorを使用
vim.opt.winblend = 20          -- ウィンドウを半透明に
vim.opt.pumblend = 20          -- 補完メニューを半透明に
vim.opt.signcolumn = "yes"     -- エラー表示用の列を常に表示

-- インデント系
vim.opt.tabstop = 4            -- タブを4スペース分
vim.opt.shiftwidth = 4         -- 自動インデントの幅
vim.opt.expandtab = true       -- タブをスペースに変換

-- 検索系 (追加しておくと便利です)
vim.opt.ignorecase = true      -- 大文字小文字を無視
vim.opt.smartcase = true       -- 大文字が含まれる場合は区別