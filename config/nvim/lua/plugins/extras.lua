-- ~/.config/nvim/lua/plugins/extras.lua
return {
  -- Treesitter
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

  -- Copilot Chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken",
    opts = {
      window = { layout = 'float', width = 0.6, height = 0.6 },
    },
    config = function(_, opts)
      require("copilot").setup({
        suggestion = { enabled = true, auto_trigger = true },
        panel = { enabled = true },
      })
      require("CopilotChat").setup(opts)

      -- キーマップ
      vim.keymap.set('n', '<leader>cc', require("CopilotChat").toggle, { desc = "Toggle Copilot Chat" })
      vim.keymap.set('v', '<leader>ce', "<cmd>CopilotChatExplain<cr>", { desc = "Explain Code" })
      vim.keymap.set('v', '<leader>cf', "<cmd>CopilotChatFix<cr>", { desc = "Fix Code" })
    end,
  },
}