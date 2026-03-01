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
# 2. CapsLock → F18 リマップ (現在のセッション)
# ----------------------------------------
echo "CapsLock → F18 にリマップ..."
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x70000006D}]}' > /dev/null

# ----------------------------------------
# 3. CapsLock → F18 リマップ (起動時に自動実行)
# ----------------------------------------
PLIST_SRC="$DOTFILES_DIR/config/launchagents/com.ayuayuyu.capslock-remap.plist"
PLIST_DST="$HOME/Library/LaunchAgents/com.ayuayuyu.capslock-remap.plist"

if [ -f "$PLIST_SRC" ]; then
    mkdir -p "$HOME/Library/LaunchAgents"
    ln -snfv "$PLIST_SRC" "$PLIST_DST"
    echo "LaunchAgent を登録しました（再起動後も CapsLock → F18 が有効になります）"
else
    echo "⚠️  LaunchAgent plist が見つかりません: $PLIST_SRC"
fi

# ----------------------------------------
# 4. 入力ソース切り替えショートカットを F18 に設定
# ----------------------------------------
echo "入力ソース切り替えショートカットを F18 に設定..."
# HotKey 61: 前の入力ソースを選択
# parameters: { key=F18(0x4D=77), modifiers=0(修飾キーなし) }
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 '
<dict>
    <key>enabled</key>
    <true/>
    <key>value</key>
    <dict>
        <key>parameters</key>
        <array>
            <integer>65535</integer>
            <integer>77</integer>
            <integer>0</integer>
        </array>
        <key>type</key>
        <string>standard</string>
    </dict>
</dict>'

# ----------------------------------------
# 5. Raycast 設定のインポート案内
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
echo "  - 入力ソース切り替えショートカット (F18)"
echo "  - CapsLock → F18 リマップ (LaunchAgent)"
echo ""
echo "※ CapsLock → F18 リマップは現在のセッションにも即座に適用済みです。"
