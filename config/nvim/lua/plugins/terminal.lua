-- ~/.config/nvim/lua/plugins/terminal.lua
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 20,
      open_mapping = [[<C-t>]],
      direction = 'horizontal',
      float_opts = {
        border = 'curved',
      },
    })

    -- 通常ターミナル用キーマップ（lazygit / claudecode には適用しない）
    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)
      vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
      vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    end

    -- TermOpen時: lazygit / claude は Esc を Neovim に奪わせない
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*",
      callback = function()
        local buf_name = vim.api.nvim_buf_get_name(0)
        if not buf_name:find("lazygit") and not buf_name:find("claude") then
          set_terminal_keymaps()
        end
      end,
    })
  end
}
