return {
  -- 1. Mason (インストーラー) & LSP Config
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- setupの実行順序を厳密に守る
      require("mason").setup()
      
      local mason_lspconfig = require("mason-lspconfig")
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- 先にsetup_handlersを定義してしまう（順序依存対策）
      mason_lspconfig.setup({
        ensure_installed = {
          "gopls",
          "ts_ls",
          "lua_ls",
          "pyright",
          "rust_analyzer",
          "tailwindcss",
          "eslint",
          "jsonls",
          "yamlls",
          "bashls",
        },
        handlers = {
          function(server_name)
            lspconfig[server_name].setup({
              capabilities = capabilities,
            })
          end,
        }
      })

      -- ツール(フォーマッター等)のインストール設定
      require("mason-tool-installer").setup({
        ensure_installed = {
          "prettier",
          "goimports",
          "stylua",
          "ruff",
          "shfmt",
        },
      })

      -- LSPキーマップ
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Hover Documentation" })
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Go to Definition" })
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = "Go to Declaration" })
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = "Go to References" })
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = "Go to Implementation" })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = "Code Action" })
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = "Rename Symbol" })
      vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, { desc = "Type Definition" })
      vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Prev Diagnostic" })
      vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next Diagnostic" })
    end,
  },

  -- 2. Auto Formatting (Conform)
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    opts = {
      format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        go = { "goimports", "gofmt" },
        lua = { "stylua" },
        python = { "ruff_format", "ruff_fix" },
        sh = { "shfmt" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
      },
    },
  },

  -- 3. Completion (Cmp)
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
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
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
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
}