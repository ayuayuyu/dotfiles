-- ~/.config/nvim/lua/plugins/extras.lua
return {
  -- 1. Treesitter (シンタックスハイライト強化)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "lua", "vim", "go", "javascript", "typescript", "tsx", "json", "markdown" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- 2. Which-key (キーバインド一覧をポップアップ表示)
  --    <leader> を押して少し待つと、使えるキーの一覧が出ます
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      -- グループ名を設定（ポップアップに分かりやすい名前を表示）
      wk.add({
        { "<leader>a",  group = "AI: Claude Code" },
        { "<leader>c",  group = "AI: Copilot Chat" },
        { "<leader>g",  group = "Git" },
        { "<leader>f",  group = "Find (Telescope)" },
        { "<leader>x",  group = "Trouble (Diagnostics)" },
        { "<leader>b",  group = "Buffer" },
        { "<leader>r",  group = "REST API" },
      })
    end,
  },

  -- 3. Trouble.nvim (VSCode の「問題」パネル相当)
  --    <leader>xx で全エラー一覧を表示
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (Trouble)" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",      desc = "Symbols (Trouble)" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false<cr>",          desc = "LSP Definitions (Trouble)" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix List" },
    },
    opts = {
      modes = {
        diagnostics = {
          auto_open = false,
          auto_close = true,
        },
      },
    },
  },
}
