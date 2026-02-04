-- ==========================================
-- 0. 基本設定 (見た目や操作の基本)
-- ==========================================
vim.opt.number = true          -- 行番号を表示
vim.opt.cursorline = true      -- 現在の行をハイライト
vim.opt.termguicolors = true   -- True Colorを使用
vim.opt.winblend = 20          -- ウィンドウを半透明に
vim.opt.pumblend = 20          -- 補完メニューを半透明に
vim.opt.signcolumn = "yes"     -- エラー表示用の列を常に表示(ガタつき防止)

-- インデント系
vim.opt.tabstop = 4            -- タブを4スペース分
vim.opt.shiftwidth = 4         -- 自動インデントの幅
vim.opt.expandtab = true       -- タブをスペースに変換

-- キーマップ (リーダーキーをスペースに設定)
vim.g.mapleader = " "
vim.keymap.set("n", "<Space>e", ":Neotree toggle<CR>", { silent = true })

-- ==========================================
-- 1. プラグインマネージャー (lazy.nvim) の自動インストール
-- ==========================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================
-- 2. プラグインのリストと設定
-- ==========================================
require("lazy").setup({

  -- 【見た目】カラースキーム (TokyoNight)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },

  -- 【見た目】ステータスライン (Lualine)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({ options = { theme = "tokyonight" } })
    end,
  },

  -- 【Git】行の変更状態を表示 (Gitsigns)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- 【機能】ファイル検索 (Telescope)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep Text" },
    },
  },

  -- 【機能】ファイルツリー (Neo-tree)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
  },

  -- 【構文解析】Treesitter (Go, TS, JSなどのハイライト)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "lua", "vim", "go", "javascript", "typescript", "tsx", "json", "markdown" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- ==========================================
  -- AI & Copilot 関連
  -- ==========================================
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- Copilot本体
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken",
    opts = {
      window = { layout = 'float', width = 0.6, height = 0.6 },
    },
    config = function(_, opts)
      -- Copilot本体の設定
      require("copilot").setup({
        suggestion = { enabled = true, auto_trigger = true }, -- 入力中にゴーストテキストを表示
        panel = { enabled = true },
      })
      -- Chatの設定
      require("CopilotChat").setup(opts)

      -- キーマップ
      vim.keymap.set('n', '<leader>cc', require("CopilotChat").toggle, { desc = "Toggle Copilot Chat" })
      vim.keymap.set('v', '<leader>ce', "<cmd>CopilotChatExplain<cr>", { desc = "Explain Code" })
      vim.keymap.set('v', '<leader>cf', "<cmd>CopilotChatFix<cr>", { desc = "Fix Code" })
    end,
  },

  -- ==========================================
  -- LSP (言語サーバー) / 補完 / フォーマッター
  -- ==========================================
  
  -- 1. Mason (インストーラー)
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      require("mason").setup()

      -- 言語サーバーのリスト定義
      require("mason-lspconfig").setup({
        ensure_installed = { 
          "gopls", 
          "ts_ls", 
          "lua_ls" -- 【修正】lua_language_server から変更
        },
      })
      
      -- ツール(フォーマッター等)のリスト定義
      require("mason-tool-installer").setup({
        ensure_installed = {
          "prettier",     -- TS/JS Formatter
          "goimports",    -- Go Formatter
          "gofmt",
        },
      })
    end,
  },

  -- 2. LSP Config (サーバーの設定)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Masonでインストールしたサーバーを自動セットアップ
      mason_lspconfig.setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
          })
        end,
      })

      -- LSP関連のキーマップ
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})             -- カーソル下の説明表示
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})       -- 定義ジャンプ
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {}) -- クイックフィックス
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {})    -- 前のエラーへ
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {})    -- 次のエラーへ
    end,
  },

  -- 3. Auto Formatting (保存時に整形)
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        go = { "goimports", "gofmt" },
        lua = { "stylua" },
      },
    },
  },

  -- 4. Completion (自動補完 & スニペット)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSPからの補完
      "hrsh7th/cmp-buffer",   -- バッファ内の単語補完
      "hrsh7th/cmp-path",     -- パス補完
      "L3MON4D3/LuaSnip",     -- スニペットエンジン
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(), -- 次の候補
          ["<C-p>"] = cmp.mapping.select_prev_item(), -- 前の候補
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- 決定
          ["<C-Space>"] = cmp.mapping.complete(), -- 手動で補完を開く
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

})