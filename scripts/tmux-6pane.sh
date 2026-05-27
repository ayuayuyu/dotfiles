#!/bin/bash
# 6分割均等レイアウト
# ┌───┬───┬───┐
# │ 1 │ 2 │ 3 │
# ├───┼───┼───┤
# │ 4 │ 5 │ 6 │
# └───┴───┴───┘

# tmux内から実行: 現在のウィンドウを6分割
if [[ -n "$TMUX" ]]; then
  # 上下に50%で分割
  tmux split-window -v -p 50

  # 上段(ペイン1)を3等分
  tmux select-pane -t 1
  tmux split-window -h -p 66
  tmux split-window -h -p 50

  # 下段(ペイン4)を3等分
  tmux select-pane -t 4
  tmux split-window -h -p 66
  tmux split-window -h -p 50

  # 左上(ペイン1)を選択
  tmux select-pane -t 1
  exit 0
fi

# tmux外から実行: 新規セッション作成
SESSION="${1:-main}"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux attach -t "$SESSION"
  exit 0
fi

tmux new-session -d -s "$SESSION"

tmux split-window -v -p 50
tmux select-pane -t 1
tmux split-window -h -p 66
tmux split-window -h -p 50
tmux select-pane -t 4
tmux split-window -h -p 66
tmux split-window -h -p 50
tmux select-pane -t 1

tmux attach -t "$SESSION"
