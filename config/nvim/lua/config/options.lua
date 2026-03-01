-- 基本設定
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.number = true         -- 行番号を表示
vim.opt.relativenumber = true -- 相対行番号（j/k での移動距離がわかりやすい）
vim.opt.cursorline = true     -- 現在の行をハイライト
vim.opt.termguicolors = true  -- True Color を使用
vim.opt.winblend = 20         -- ウィンドウを半透明に
vim.opt.pumblend = 20         -- 補完メニューを半透明に
vim.opt.signcolumn = "yes"    -- エラー表示用の列を常に表示
vim.opt.clipboard = "unnamedplus"

-- インデント系
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- 検索系
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- スクロール余白（カーソルの上下に8行のスペースを確保）
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- ウィンドウ分割の方向（VSCode に近い挙動）
vim.opt.splitbelow = true  -- 水平分割は下に開く
vim.opt.splitright = true  -- 垂直分割は右に開く

-- アンドゥ履歴を永続化（再起動後もUndo可能）
vim.opt.undofile = true
