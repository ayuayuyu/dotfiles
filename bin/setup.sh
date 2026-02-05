#!/bin/bash

# エラーが発生したら即終了、未定義変数の使用で終了
set -eu

# スクリプトがあるディレクトリ（dotfilesルート）を起点にする
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

echo "セットアップを開始"
echo "dotfiles location: $DOTFILES_DIR"

# ----------------------------------------
# 1. HomebrewのインストールとBundle
# ----------------------------------------
if ! command -v brew &> /dev/null; then
    echo "🍺 Homebrewが見つからないため、インストールします..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Apple Silicon Mac等の場合、現在のシェルにパスを通す
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "Homebrewは既にインストールされています。"
fi

# Brewfileの実行
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    echo "Brewfileを用いてパッケージをインストール"
    # 失敗しても止まらないように '|| true' をつけるか、set -e配下ならエラーハンドリングする
    brew bundle --file="$DOTFILES_DIR/Brewfile" || echo "一部のパッケージインストールに失敗しましたが続行します。"
else
    echo "スキップ: 'Brewfile' が見つかりません。"
fi

# ----------------------------------------
# 2. Preztoのインストール (Zshフレームワーク)
# ----------------------------------------
ZPREZTO_DIR="${ZDOTDIR:-$HOME}/.zprezto"
if [ ! -d "$ZPREZTO_DIR" ]; then
    echo "Preztoをインストール"
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "$ZPREZTO_DIR"
else
    echo "Preztoは既にインストールされています。"
fi

# ----------------------------------------
# 3. シンボリックリンクの作成
# ----------------------------------------
echo "シンボリックリンクを作成"

# 関数: リンク作成の共通ロジック
# link_file "元ファイル" "リンク先パス"
link_file() {
    local src=$1
    local dst=$2
    # 親ディレクトリがない場合は作成
    mkdir -p "$(dirname "$dst")"
    # -s: シンボリックリンク, -n: リンク先がディレクトリ扱いの回避, -f: 強制上書き, -v: 詳細
    ln -snfv "$src" "$dst"
}

# zshフォルダ -> $HOME/.ファイル名
if [ -d "$DOTFILES_DIR/zsh" ]; then
    for file in "$DOTFILES_DIR"/zsh/*; do
        # ファイルが存在しない、または .DS_Store などの場合はスキップ
        [ -e "$file" ] || continue
        case "$(basename "$file")" in
            .DS_Store|README.md) continue ;;
        esac

        filename="$(basename "$file")"
        # ファイル名がドットで始まっていなければドットをつける
        if [[ "$filename" == .* ]]; then
            target="$HOME/$filename"
        else
            target="$HOME/.$filename"
        fi
        
        link_file "$file" "$target"
    done
fi

# configフォルダ -> $HOME/.config/フォルダ名
if [ -d "$DOTFILES_DIR/config" ]; then
    echo "📂 .config 関連のリンクを作成中..."
    mkdir -p "$HOME/.config"
    for file in "$DOTFILES_DIR"/config/*; do
        [ -e "$file" ] || continue
        case "$(basename "$file")" in
            .DS_Store|README.md) continue ;;
        esac

        filename="$(basename "$file")"
        target="$HOME/.config/$filename"
        
        link_file "$file" "$target"
    done``
fi

# WezTerm (wezterm.lua -> $HOME/.wezterm.lua)
if [ -f "$DOTFILES_DIR/wezterm.lua" ]; then
    link_file "$DOTFILES_DIR/wezterm.lua" "$HOME/.wezterm.lua"
fi

echo "Done！"
