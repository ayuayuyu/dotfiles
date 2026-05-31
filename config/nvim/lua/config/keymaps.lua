-- ==========================================
-- 基本操作
-- ==========================================
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("i", "jk", "<Esc>")
-- Esc連打でハイライトを消す
vim.keymap.set("n", "<Esc><Esc>", ":nohlsearch<CR>", { desc = "Clear Highlight" })

-- ==========================================
-- バッファ（タブ）操作
-- ==========================================
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next Buffer" })
vim.keymap.set("n", "<S-h>", ":bprev<CR>", { desc = "Previous Buffer" })
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete Buffer" })

-- ==========================================
-- ウィンドウ分割・移動 (Ctrl + h/j/k/l)
-- ==========================================
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window Left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window Down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window Up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window Right" })

-- ウィンドウサイズ調整 (Alt + 矢印)
vim.keymap.set("n", "<A-Up>",    "<cmd>resize +2<CR>",          { desc = "Increase Window Height" })
vim.keymap.set("n", "<A-Down>",  "<cmd>resize -2<CR>",          { desc = "Decrease Window Height" })
vim.keymap.set("n", "<A-Left>",  "<cmd>vertical resize -2<CR>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<A-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase Window Width" })

-- ==========================================
-- 行の移動 (Alt + j/k)
-- ==========================================
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<CR>==",        { desc = "Move Line Down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<CR>==",        { desc = "Move Line Up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv",        { desc = "Move Selection Down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv",        { desc = "Move Selection Up" })
vim.keymap.set("i", "<A-j>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move Line Down" })
vim.keymap.set("i", "<A-k>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move Line Up" })

-- ==========================================
-- ビジュアルモード便利操作
-- ==========================================
-- インデント後もビジュアル選択を維持
vim.keymap.set("v", "<", "<gv", { desc = "Indent Left (keep selection)" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent Right (keep selection)" })

-- ==========================================
-- スクロール・検索の改善
-- ==========================================
-- スクロール時にカーソルを画面中央に維持
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up (centered)" })
-- 検索ジャンプ時にカーソルを画面中央に維持
vim.keymap.set("n", "n", "nzzzv", { desc = "Next Search (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev Search (centered)" })
-- J（行結合）でカーソル位置を維持
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join Lines (keep cursor)" })

-- ==========================================
-- 検索・置換
-- ==========================================
vim.keymap.set("n", "<leader>sr", ":%s///gc<Left><Left><Left><Left>", { desc = "Search & Replace" })
vim.keymap.set("v", "<leader>sr", ":s///gc<Left><Left><Left><Left>",  { desc = "Search & Replace (selection)" })
