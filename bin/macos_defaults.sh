#!/bin/bash

# macOS固有の設定スクリプト
# setup.sh から source で呼び出される

echo ""
echo "=== macOS 固有設定 ==="

# ----------------------------------------
# 1. スクロール方向をナチュラルに設定
# ----------------------------------------
echo "スクロール方向をナチュラルに設定..."
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

# ----------------------------------------
# 2. Raycast 設定のインポート案内
# ----------------------------------------
RAYCONFIG_DIR="$DOTFILES_DIR/config/raycast"
if [ -d "$RAYCONFIG_DIR" ] && ls "$RAYCONFIG_DIR"/*.rayconfig 1>/dev/null 2>&1; then
    RAYCONFIG_FILE="$(ls -1 "$RAYCONFIG_DIR"/*.rayconfig | head -n 1)"
    echo ""
    echo "=== Raycast 設定のインポート ==="
    echo "Raycast の設定ファイルが見つかりました。"
    echo "以下のコマンドでインポートできます:"
    echo "  open \"$RAYCONFIG_FILE\""
    echo ""
    printf "今すぐインポートしますか？ [y/N]: "
    read -r IMPORT_RAYCAST < /dev/tty
    if [[ "$IMPORT_RAYCAST" =~ ^[Yy]$ ]]; then
        open "$RAYCONFIG_FILE"
        echo "Raycast が設定ファイルを開きます。画面の指示に従ってインポートしてください。"
    fi
else
    echo ""
    echo "📝 Raycast 設定のエクスポート方法:"
    echo "   1. Raycast を開く → Settings → Advanced"
    echo "   2. 「Export」で .rayconfig ファイルをエクスポート"
    echo "   3. エクスポートしたファイルを以下に配置:"
    echo "      $RAYCONFIG_DIR/"
fi

# ----------------------------------------
# 設定反映の案内
# ----------------------------------------
echo ""
echo "=== 設定反映について ==="
echo "以下の設定は再ログインまたは再起動後に反映されます:"
echo "  - スクロール方向"
