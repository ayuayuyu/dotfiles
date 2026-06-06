{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;

    plugins = with pkgs.tmuxPlugins; [
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
        '';
      }
    ];

    # 詳細設定:
    #   - Ghostty 連携部分 (terminal-features 等) は Nix モジュール側のみ
    #   - 汎用 tmux 設定 (keybind / status bar 等) は config/tmux/tmux.conf に集約し
    #     bin/setup-*.sh のフォールバック経路と共有する
    #
    # NOTE: config/tmux/tmux.conf は builtins.readFile で eval 時に nix-store へ
    #       焼き込まれる。編集後は `darwin-rebuild switch` (= rebuild) で反映する。
    #       tmux 内 `prefix + r` だけでは新しい内容に切り替わらない。
    extraConfig = ''
      # ------------------------------------------------------------
      # ターミナル機能 (Ghostty 連携: Nix 経由でのみ適用)
      # ------------------------------------------------------------
      # tmux 3.2+ の terminal-features で xterm-ghostty に明示
      #   RGB:       24bit カラー
      #   clipboard: OSC 52 経由でシステムクリップボードへ
      #   usstyle:   下線スタイル (curly / dashed)
      #   title:     ウィンドウタイトル送信
      set -as terminal-features ",xterm-ghostty:RGB:clipboard:usstyle:title"

      # OSC 透過 (Ghostty shell-integration の cwd / プロンプトマーク用)
      #   有効にしないと OSC 7 / OSC 133 / 画像プロトコルが tmux に吸われる
      set -g allow-passthrough on

      # アプリへフォーカスイベント転送 (Neovim の autoread 等で必要)
      set -g focus-events on

      # tmux yank → ターミナル → OS クリップボード (OSC 52)
      set -g set-clipboard on
    '' + builtins.readFile ../config/tmux/tmux.conf;
  };
}
