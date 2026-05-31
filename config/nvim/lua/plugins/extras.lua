-- ~/.config/nvim/lua/plugins/extras.lua
return {
  -- 1. Treesitter (シンタックスハイライト強化)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
        -- Neovim core
        "c", "lua", "vim", "vimdoc", "query",
        -- Go ecosystem
        "go", "gomod", "gowork", "gosum",
        -- JavaScript / TypeScript
        "javascript", "typescript", "tsx",
        -- Python / Rust
        "python", "rust", "toml",
        -- Web / Config
        "json", "yaml", "html", "css",
        -- Markdown
        "markdown", "markdown_inline",
        -- DevOps / DB
        "bash", "dockerfile", "sql",
        -- Git
        "gitcommit", "gitignore", "diff",
      },
      highlight = { enable = true },
      indent = { enable = true },
      -- Treesitterベースの範囲選択（C-spaceで拡大、BSで縮小）
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    },
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
        { "<leader>r",  group = "REST API / Replace" },
        { "<leader>s",  group = "Search" },
        { "gz",         group = "Surround" },
        { "gc",         group = "Comment" },
        { "]",          group = "Next..." },
        { "[",          group = "Prev..." },
      })
    end,
  },

  -- 3. インデントガイド (VSCode風の縦線)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = true, show_start = false, show_end = false },
    },
  },

  -- 4. TODO/FIXME/HACK ハイライト & ジャンプ
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>",              desc = "TODOs (Trouble)" },
      { "<leader>ft", "<cmd>TodoTelescope<cr>",                    desc = "Find TODOs" },
    },
  },

  -- 5. Trouble.nvim (VSCode の「問題」パネル相当)
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
