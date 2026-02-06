-- ~/.config/nvim/lua/config/keymaps.lua

-- ※ mapleaderは init.lua で設定済み

-- 保存や終了のショートカット（お好みで）
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("i", "jk", "<Esc>")
-- Esc連打でハイライトを消す（便利なので追加）
vim.keymap.set("n", "<Esc><Esc>", ":nohlsearch<CR>", { desc = "Clear Highlight" })

-- ==========================================
-- バッファ（タブ）操作
-- ==========================================

-- Shift + l で「次のタブ」へ
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next Buffer" })

-- Shift + h で「前のタブ」へ
vim.keymap.set("n", "<S-h>", ":bprev<CR>", { desc = "Previous Buffer" })

-- Space + bd で「現在のタブを閉じる」
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete Buffer" })

