-- ~/.config/nvim/lua/plugins/editing.lua
-- 編集操作を快適にするプラグイン群
return {
  -- 1. 括弧の自動補完
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },

  -- 2. サラウンド操作
  --    gza" → カーソル位置の単語を"で囲む (例: word → "word")
  --    gzd" → 周囲の"を削除
  --    gzr"' → 周囲の"を'に置換
  {
    "echasnovski/mini.surround",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      -- flash.nvim の s キーとの競合を回避するため gz プレフィックスを使用
      mappings = {
        add = "gza",
        delete = "gzd",
        replace = "gzr",
        find = "gzf",
        find_left = "gzF",
        highlight = "gzh",
        update_n_lines = "gzn",
      },
    },
  },

  -- 3. コメントトグル
  --    gcc → 現在行のコメントをトグル
  --    gc  → ビジュアル選択範囲のコメントをトグル
  {
    "echasnovski/mini.comment",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- 4. 高速カーソルジャンプ
  --    s → 2文字入力でジャンプ先候補を表示
  --    S → Treesitterノード単位で選択
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  -- 5. Vim操作の悪習慣を矯正
  --    同じキーを連打するとヒントを表示（ブロックはしない）
  --    例: jjjj → "Use 4j or search instead"
  {
    "m4xshen/hardtime.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      restriction_mode = "hint",
      max_count = 3,
      disabled_filetypes = {
        "neo-tree",
        "lazy",
        "mason",
        "trouble",
        "help",
        "toggleterm",
        "copilot-chat",
        "TelescopePrompt",
        "DressingInput",
      },
    },
  },
}
