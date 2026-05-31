{ pkgs, config, ... }:

{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    mouse = true;
    escapeTime = 0;
    baseIndex = 1;
    historyLimit = 50000;
    keyMode = "vi";

    plugins = with pkgs.tmuxPlugins; [
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
        '';
      }
    ];

    extraConfig = ''
      # True Color 対応
      set -ga terminal-overrides ",*256col*:Tc"

      # ペイン番号を1始まりにする
      setw -g pane-base-index 1

      # ウィンドウを閉じたとき番号を詰める
      set -g renumber-windows on

      # 設定リロード
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

      # ----------------------------------------
      # vi コピーモード
      # ----------------------------------------
      bind-key -T copy-mode-vi v   send-keys -X begin-selection
      bind-key -T copy-mode-vi V   send-keys -X select-line
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y   send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi H   send-keys -X start-of-line
      bind-key -T copy-mode-vi L   send-keys -X end-of-line

      # ----------------------------------------
      # ペイン操作 (vim 風)
      # ----------------------------------------

      # 分割: v で縦分割, s で横分割
      bind v split-window -h -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # ペイン移動: hjkl
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # ペインリサイズ: Shift + hjkl
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # ----------------------------------------
      # ステータスバー (Tokyo Night)
      # ----------------------------------------
      set -g status-position bottom
      set -g status-style "bg=#0f1419,fg=#7aa2f7"
      set -g status-left-length 40
      set -g status-right-length 60

      set -g status-left "#[fg=#00d4ff,bold] #S #[fg=#7aa2f7]│ "
      set -g status-right "#[fg=#7aa2f7]%Y-%m-%d #[fg=#00d4ff,bold]%H:%M "

      setw -g window-status-format         "#[fg=#7aa2f7] #I:#W "
      setw -g window-status-current-format "#[fg=#0f1419,bg=#00d4ff,bold] #I:#W "

      # ペインボーダー
      set -g pane-border-style        "fg=#1f2335"
      set -g pane-active-border-style "fg=#00d4ff"

      # ----------------------------------------
      # 便利機能
      # ----------------------------------------

      # 新しいウィンドウでカレントパスを引き継ぐ
      bind c new-window -c "#{pane_current_path}"

      # 同時入力トグル
      bind S setw synchronize-panes \; display "Sync #{?pane_synchronized,ON,OFF}"

      # 新しいセッション作成
      bind C new-session

      # ペインを確認なしで閉じる
      bind X kill-pane

      # 最後のウィンドウに切り替え
      bind Tab last-window

      # ペインにマーク
      bind m select-pane -m

      # ----------------------------------------
      # クリップボード連携 (macOS)
      # ----------------------------------------
      if-shell "uname | grep -q Darwin" \
        'bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"'
    '';
  };
}
