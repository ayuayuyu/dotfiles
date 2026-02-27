#!/bin/bash

# エラーが発生したら即終了、未定義変数の使用で終了
set -eu

# スクリプトがあるディレクトリ（dotfilesルート）を起点にする
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# OS検出
OS_TYPE="$(uname -s)"

echo "セットアップを開始"
echo "dotfiles location: $DOTFILES_DIR"
echo "OS: $OS_TYPE"

# ----------------------------------------
# 1. パッケージのインストール
# ----------------------------------------

if [ "$OS_TYPE" = "Darwin" ]; then
    # ---- macOS: Homebrew ----
    if ! command -v brew &> /dev/null; then
        echo "🍺 Homebrewが見つからないため、インストールします..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Apple Silicon Mac
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        # Intel Mac
        elif [ -f "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo "Homebrewは既にインストールされています。"
    fi

    if [ -f "$DOTFILES_DIR/Brewfile" ]; then
        echo "Brewfileを用いてパッケージをインストール..."
        brew bundle --file="$DOTFILES_DIR/Brewfile" || echo "一部のパッケージインストールに失敗しましたが続行します。"
    else
        echo "スキップ: 'Brewfile' が見つかりません。"
    fi

elif [ "$OS_TYPE" = "Linux" ]; then
    # ---- Linux ----
    echo "Linux環境を検出しました。"

    # Homebrewの依存関係をシステムパッケージマネージャーでインストール
    if command -v apt-get &> /dev/null; then
        echo "apt でビルド依存関係をインストール..."
        sudo apt-get update -qq
        sudo apt-get install -y build-essential procps curl file git
    elif command -v dnf &> /dev/null; then
        echo "dnf でビルド依存関係をインストール..."
        sudo dnf groupinstall -y 'Development Tools'
        sudo dnf install -y procps-ng curl file git
    elif command -v pacman &> /dev/null; then
        echo "pacman でビルド依存関係をインストール..."
        sudo pacman -Sy --needed --noconfirm base-devel procps-ng curl git
    fi

    # Linuxbrew (Homebrew on Linux) のインストール
    if ! command -v brew &> /dev/null; then
        echo "🍺 Homebrew (Linux) をインストールします..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Linuxbrew のパスを通す
    if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [ -f "$HOME/.linuxbrew/bin/brew" ]; then
        eval "$($HOME/.linuxbrew/bin/brew shellenv)"
    fi

    # Linux用Brewfileを優先、なければ共通Brewfileを使用
    if [ -f "$DOTFILES_DIR/Brewfile.linux" ]; then
        echo "Brewfile.linux を用いてパッケージをインストール..."
        brew bundle --file="$DOTFILES_DIR/Brewfile.linux" || echo "一部のパッケージインストールに失敗しましたが続行します。"
    elif [ -f "$DOTFILES_DIR/Brewfile" ]; then
        echo "Brewfile を用いてパッケージをインストール..."
        brew bundle --file="$DOTFILES_DIR/Brewfile" || echo "一部のパッケージインストールに失敗しましたが続行します。"
    fi
else
    echo "未対応のOS: $OS_TYPE"
    exit 1
fi

# ----------------------------------------
# 2. Preztoのインストール (Zshフレームワーク)
# ----------------------------------------
ZPREZTO_DIR="${ZDOTDIR:-$HOME}/.zprezto"
if [ ! -d "$ZPREZTO_DIR" ]; then
    echo "Preztoをインストール..."
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "$ZPREZTO_DIR"
else
    echo "Preztoは既にインストールされています。"
fi

# ----------------------------------------
# 3. シンボリックリンクの作成
# ----------------------------------------
echo "シンボリックリンクを作成..."

# 関数: リンク作成の共通ロジック
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
        [ -e "$file" ] || continue
        case "$(basename "$file")" in
            .DS_Store|README.md) continue ;;
        esac

        filename="$(basename "$file")"
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

        filename="$(basename "$file")"

        # macOS専用アプリの設定はmacOSのみリンク
        if [ "$OS_TYPE" != "Darwin" ]; then
            case "$filename" in
                raycast) continue ;;
            esac
        fi

        case "$filename" in
            .DS_Store|README.md) continue ;;
        esac

        target="$HOME/.config/$filename"
        link_file "$file" "$target"
    done
fi

# ----------------------------------------
# 4. mise でランタイムをインストール (macOS)
# ----------------------------------------
if [ "$OS_TYPE" = "Darwin" ]; then
    if command -v mise &> /dev/null; then
        echo "mise でランタイムをインストール..."
        # シンボリックリンク作成後なので ~/.config/mise/config.toml が有効
        mise install || echo "mise のインストールで一部失敗しましたが続行します。"
    else
        echo "スキップ: mise が見つかりません (Homebrew のセットアップを確認してください)。"
    fi
fi

echo "Done！"
