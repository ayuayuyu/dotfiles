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
