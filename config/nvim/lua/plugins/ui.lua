-- ~/.config/nvim/lua/plugins/ui.lua
return {
  -- 1. カラースキーム (TokyoNight)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },

  -- 2. ステータスライン (画面下)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({ options = { theme = "tokyonight" } })
    end,
  },

  -- 3. バッファーライン (画面上のタブバー) ★新規追加
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers", -- タブではなくバッファを表示
          diagnostics = "nvim_lsp", -- エラーがあればアイコンを表示
          -- 左側のNeo-treeの分だけずらす設定
          offsets = {
            {
              filetype = "neo-tree",
              text = "File Explorer",
              highlight = "Directory",
              separator = true,
            }
          },
        }
      })
    end,
  },

  -- 4. ファイル検索 (Telescope)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep Text" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" }, -- バッファ検索も追加
    },
  },

  -- 5. ファイルツリー (Neo-tree)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      filesystem = {
        follow_current_file = { enabled = true, leave_dirs_open = true },
        hijack_netrw_behavior = "open_default",
      },
    },
    config = function(_, opts)
      require("neo-tree").setup(opts)
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.argc() == 0 then
            vim.cmd("Neotree show")
          end
        end,
      })
    end,
    keys = {
      { "<Space>e", "<cmd>Neotree toggle<CR>", desc = "Toggle Explorer" }
    }
  },
}