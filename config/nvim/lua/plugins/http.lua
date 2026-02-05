-- ~/.config/nvim/lua/plugins/http.lua
return {
  "mistweaverco/kulala.nvim",
  config = function()
    require("kulala").setup()

    -- キーマップ設定
    -- .http または .rest ファイルを開いている時に Space + rr で実行
    vim.keymap.set("n", "<leader>rr", "<cmd>lua require('kulala').run()<cr>", { desc = "APIリクエストを実行" })
    
    -- Space + rt で結果表示の切り替え（ヘッダーのみ/本文のみなど）
    vim.keymap.set("n", "<leader>rt", "<cmd>lua require('kulala').toggle_view()<cr>", { desc = "結果表示の切り替え" })
  end
}
