#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Export Notes to GitHub
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📝
# @raycast.packageName Notes

# Documentation:
# @raycast.description Raycast Notesをエクスポートして~/notes/に保存し、GitHubにpushする

NOTES_DIR="$HOME/notes"

# Raycast Floating NotesのエクスポートをAppleScriptで自動化
osascript <<'APPLESCRIPT'
-- Raycast Notesのエクスポートダイアログを開く (Cmd+Shift+E)
tell application "System Events"
    -- Raycastにフォーカス
    tell process "Raycast"
        set frontmost to true
        delay 0.5
        -- エクスポートショートカット
        keystroke "e" using {command down, shift down}
        delay 1.0
    end tell

    -- 保存ダイアログの操作
    tell process "Raycast"
        -- Markdownを選択（フォーマットのポップアップを操作）
        -- ダイアログが表示されるのを待つ
        delay 0.5

        -- 保存先を ~/notes/ に設定
        -- Cmd+Shift+G で「フォルダへ移動」を開く
        keystroke "g" using {command down, shift down}
        delay 0.5

        -- パスを入力
        keystroke "~/notes/"
        delay 0.3
        keystroke return
        delay 0.5

        -- 保存ボタンをクリック
        keystroke return
        delay 0.5
    end tell
end tell
APPLESCRIPT

# エクスポート完了を待つ
sleep 1

# Git操作
cd "$NOTES_DIR" || exit 1

# 新しいファイルがあればコミットしてpush
if [ -n "$(git status --porcelain)" ]; then
    git add -A
    git commit -m "notes: $(date '+%Y-%m-%d %H:%M') のメモを更新"
    git push origin main 2>/dev/null || echo "リモートが未設定です。先に gh repo create を実行してください。"
    echo "ノートをGitHubにpushしました"
else
    echo "変更なし"
fi
