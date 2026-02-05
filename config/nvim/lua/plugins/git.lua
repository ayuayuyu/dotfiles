-- ~/.config/nvim/lua/plugins/git.lua
return {
  -- 1. 変更箇所の表示 (Gitsigns)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        current_line_blame = true, -- 行末に誰が変更したかを表示（便利なのでONにしました）
      })
    end,
  },

  -- 2. Git操作GUI (LazyGit) ★新規追加
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      -- スペース + gg でLazyGitを開く
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    }
  }
}