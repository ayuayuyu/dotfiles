-- ~/.config/nvim/lua/plugins/git.lua
-- Git 操作キーマップ一覧:
-- <leader>gg : LazyGit を開く（全画面フロート、操作をNeovimに奪われない）
-- <leader>gf : 現在のファイルのLazyGitを開く
-- <leader>gd : Diffview（変更差分を横並びで表示）
-- <leader>gh : ファイルの変更履歴
-- <leader>gx : Diffview を閉じる
-- ]h / [h   : 次/前のgit hunksへ移動
-- <leader>gs : hunk をステージ
-- <leader>gp : hunk をプレビュー
-- <leader>gb : 行のgit blame

return {
  -- 1. 変更箇所の表示 (Gitsigns) + hunk操作
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- hunk 間の移動
          map('n', ']h', function()
            if vim.wo.diff then return ']h' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, { expr = true, desc = "Next Hunk" })

          map('n', '[h', function()
            if vim.wo.diff then return '[h' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, { expr = true, desc = "Prev Hunk" })

          -- hunk 操作
          map('n', '<leader>gs', gs.stage_hunk, { desc = "Stage Hunk" })
          map('n', '<leader>gp', gs.preview_hunk, { desc = "Preview Hunk" })
          map('n', '<leader>gb', gs.blame_line, { desc = "Blame Line" })
          map('n', '<leader>gS', gs.stage_buffer, { desc = "Stage Buffer" })
          map('n', '<leader>gu', gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
        end,
      })
    end,
  },

  -- 2. LazyGit (全画面フロート)
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
    config = function()
      -- 全画面に近いフロートで開く
      vim.g.lazygit_floating_window_winblend = 0
      vim.g.lazygit_floating_window_scaling_factor = 0.95
      vim.g.lazygit_floating_window_border_chars = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }
      vim.g.lazygit_use_neovim_remote = 0  -- neovim-remote なしでも動作するように
    end,
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
      { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit Current File" },
    },
  },

  -- 3. Diffview (横並び差分 + ファイル変更履歴)
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History" },
      { "<leader>gx", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",  -- 左右並べて差分表示
        },
      },
      file_panel = {
        listing_style = "tree",
        win_config = { width = 35 },
      },
    },
  },
}
