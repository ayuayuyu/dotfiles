#!/bin/bash
# 4分割均等レイアウト (2×2)
# ┌───┬───┐
# │ 1 │ 2 │
# ├───┼───┤
# │ 3 │ 4 │
# └───┴───┘

if [[ -n "$TMUX" ]]; then
  tmux split-window -v -p 50
  tmux select-pane -t 1
  tmux split-window -h -p 50
  tmux select-pane -t 3
  tmux split-window -h -p 50
  tmux select-pane -t 1
  exit 0
fi

SESSION="${1:-main}"
if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux attach -t "$SESSION"
  exit 0
fi

tmux new-session -d -s "$SESSION"
tmux split-window -v -p 50
tmux select-pane -t 1
tmux split-window -h -p 50
tmux select-pane -t 3
tmux split-window -h -p 50
tmux select-pane -t 1
tmux attach -t "$SESSION"
