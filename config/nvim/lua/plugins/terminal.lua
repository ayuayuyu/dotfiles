-- ~/.config/nvim/lua/plugins/terminal.lua
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 20,                    -- ターミナルの高さ
      open_mapping = [[<C-t>]],     -- 「Ctrl + t」で開閉（使いやすいキーに変更可）
      direction = 'horizontal',     -- 'horizontal': 下、'float': 浮遊、'vertical': 右
      float_opts = {
        border = 'curved',
      },
    })

    -- ターミナル内でのキーマップ設定
    -- (Escキーでターミナルモードから抜けられるようにする設定)
    function _G.set_terminal_keymaps()
      local opts = {buffer = 0}
      -- Esc または jk で、ターミナルの入力モードを抜けてVimの操作に戻る
      vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)
      vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
      -- ウィンドウ移動のショートカット (Ctrl + h/j/k/l)
      vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    end

    -- ターミナルを開いたときに上記キーマップを適用
    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
  end
}