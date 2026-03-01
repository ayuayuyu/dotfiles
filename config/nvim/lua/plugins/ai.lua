-- ~/.config/nvim/lua/plugins/ai.lua
--
-- Claude Code Chat キーマップ:
--   <leader>ac  : Claude Code Chat を開く/閉じる
--   <leader>af  : Claude Code にフォーカスを移す
--   <leader>as  : 選択範囲を Claude に送る (visual mode)
--   <leader>ab  : 現在のバッファを Claude のコンテキストに追加
--   <leader>aA  : diff を承認（Claude が提案した変更を適用）
--   <leader>aD  : diff を却下
--
-- Copilot Chat キーマップ:
--   <leader>cc  : Copilot Chat パネルを開く/閉じる
--   <leader>ce  : 選択コードを説明させる (visual mode)
--   <leader>cf  : 選択コードを修正させる (visual mode)
--   <leader>cr  : 選択コードをレビューさせる (visual mode)

return {
  -- ============================================================
  -- 1. snacks.nvim (claudecode.nvim が使用するターミナルUI)
  --    他のプラグインと競合しないよう terminal 機能のみ有効化
  -- ============================================================
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      terminal = { enabled = true },
      -- 既存プラグインと競合する機能は無効化
      dashboard    = { enabled = false },
      notifier     = { enabled = false },
      picker       = { enabled = false },  -- Telescope を使用
      lazygit      = { enabled = false },  -- lazygit.nvim を使用
      indent       = { enabled = false },
      scroll       = { enabled = false },
      statuscolumn = { enabled = false },
      words        = { enabled = false },
    },
  },

  -- ============================================================
  -- 2. Claude Code Chat (coder/claudecode.nvim)
  --    VSCode 拡張と同じ WebSocket MCP プロトコルを実装。
  --    Claude が現在開いているファイル・選択範囲を自動で把握し、
  --    diff のプレビューと承認/却下もできます。
  -- ============================================================
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      -- ターミナルの表示方向: "vertical" で右側にチャットパネル (VSCode 風)
      split_side = "right",
      split_width_percentage = 0.38,
      -- テーマに合わせたハイライト
      diff_opts = {
        auto_close_on_accept = true,  -- 承認したら diff ウィンドウを自動で閉じる
      },
    },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>",           desc = "Claude Code Chat" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",      desc = "Claude Code Focus" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",      desc = "Add Buffer to Claude" },
      { "<leader>aA", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: Accept Diff" },
      { "<leader>aD", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Claude: Deny Diff" },
      -- visual mode: 選択範囲を Claude に送る
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>",       mode = "v", desc = "Send Selection to Claude" },
    },
  },

  -- ============================================================
  -- 3. GitHub Copilot + Copilot Chat
  -- ============================================================
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    event = "VeryLazy",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken",
    opts = {
      window = { layout = 'vertical', width = 0.35 },
    },
    config = function(_, opts)
      require("copilot").setup({
        suggestion = { enabled = true, auto_trigger = true },
        panel = { enabled = true },
      })
      require("CopilotChat").setup(opts)

      vim.keymap.set('n', '<leader>cc', require("CopilotChat").toggle, { desc = "Copilot Chat Toggle" })
      vim.keymap.set('v', '<leader>ce', "<cmd>CopilotChatExplain<cr>",  { desc = "Copilot: Explain" })
      vim.keymap.set('v', '<leader>cf', "<cmd>CopilotChatFix<cr>",      { desc = "Copilot: Fix" })
      vim.keymap.set('v', '<leader>cr', "<cmd>CopilotChatReview<cr>",   { desc = "Copilot: Review" })
    end,
  },
}
