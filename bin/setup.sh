#!/bin/bash

# エラーが発生したら即終了、未定義変数の使用で終了
set -eu

# スクリプトがあるディレクトリ（dotfilesルート）を起点にする
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# OS検出
OS_TYPE="$(uname -s)"

# ----------------------------------------
# 共通関数
# ----------------------------------------

# 関数: リンク作成の共通ロジック
link_file() {
    local src=$1
    local dst=$2
    # 親ディレクトリがない場合は作成
    mkdir -p "$(dirname "$dst")"
    # -s: シンボリックリンク, -n: リンク先がディレクトリ扱いの回避, -f: 強制上書き, -v: 詳細
    ln -snfv "$src" "$dst"
}

# ヘルプ表示
show_help() {
    cat <<EOF
使い方: ./bin/setup.sh [コマンド]

コマンド:
  brew    Homebrew インストール + Brewfile によるパッケージインストール
  git     Git ユーザー設定
  ssh     SSH キー生成・GitHub 登録
  prezto  Prezto (zsh フレームワーク) インストール
  link    シンボリックリンク作成（zsh, config）
  mise    mise ランタイムインストール
  macos   macOS 固有設定（システム設定の変更）
  nvim    Neovim セットアップ（リンク + プラグイン同期）
  help    この使い方を表示

引数なしで実行すると全セットアップを順番に実行します。
EOF
}

# ----------------------------------------
# サブコマンド: brew
# ----------------------------------------
setup_brew() {
    echo ""
    echo "=== Homebrew セットアップ ==="

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
}

# ----------------------------------------
# サブコマンド: git
# ----------------------------------------
setup_git() {
    echo ""
    echo "=== Git ユーザー設定 ==="

    CURRENT_GIT_NAME="$(git config --global user.name 2>/dev/null || true)"
    CURRENT_GIT_EMAIL="$(git config --global user.email 2>/dev/null || true)"

    if [ -n "$CURRENT_GIT_NAME" ]; then
        echo "Git ユーザー名: $CURRENT_GIT_NAME (設定済み)"
    else
        printf "Git ユーザー名を入力してください: "
        read -r GIT_NAME < /dev/tty
        if [ -n "$GIT_NAME" ]; then
            git config --global user.name "$GIT_NAME"
            echo "設定しました: user.name = $GIT_NAME"
        fi
    fi

    if [ -n "$CURRENT_GIT_EMAIL" ]; then
        echo "Git メールアドレス: $CURRENT_GIT_EMAIL (設定済み)"
    else
        printf "Git メールアドレスを入力してください: "
        read -r GIT_EMAIL < /dev/tty
        if [ -n "$GIT_EMAIL" ]; then
            git config --global user.email "$GIT_EMAIL"
            echo "設定しました: user.email = $GIT_EMAIL"
        fi
    fi
}

# ----------------------------------------
# サブコマンド: ssh
# ----------------------------------------
setup_ssh() {
    echo ""
    echo "=== SSH キー設定 ==="

    SSH_KEY="$HOME/.ssh/id_ed25519"
    SSH_CONFIG="$HOME/.ssh/config"

    if [ ! -f "$SSH_KEY" ]; then
        echo "🔑 SSH キーを生成します (ed25519)..."
        SSH_EMAIL="$(git config --global user.email 2>/dev/null || echo 'your@email.com')"
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        # パスフレーズは対話的に入力 (空でもOK)
        ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$SSH_KEY"
    else
        echo "SSH キーは既に存在します: $SSH_KEY"
    fi

    # ssh-agent に追加
    eval "$(ssh-agent -s)" > /dev/null 2>&1 || true

    if [ "$OS_TYPE" = "Darwin" ]; then
        # macOS: キーチェーンに保存
        ssh-add --apple-use-keychain "$SSH_KEY" 2>/dev/null || ssh-add "$SSH_KEY" 2>/dev/null || true
    else
        ssh-add "$SSH_KEY" 2>/dev/null || true
    fi

    # ~/.ssh/config に GitHub ホスト設定を追加
    if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
        echo "~/.ssh/config に GitHub の設定を追加..."
        mkdir -p "$HOME/.ssh"
        {
            echo ""
            echo "Host github.com"
            echo "  HostName github.com"
            echo "  User git"
            echo "  IdentityFile ~/.ssh/id_ed25519"
            echo "  AddKeysToAgent yes"
            if [ "$OS_TYPE" = "Darwin" ]; then
                echo "  UseKeychain yes"
            fi
        } >> "$SSH_CONFIG"
        chmod 600 "$SSH_CONFIG"
        echo "設定を追加しました: $SSH_CONFIG"
    else
        echo "~/.ssh/config に GitHub の設定は既にあります。"
    fi

    # GitHub への SSH 公開鍵登録
    echo ""
    echo "▼ GitHub に登録する SSH 公開鍵:"
    cat "${SSH_KEY}.pub"
    echo ""

    if command -v gh &>/dev/null; then
        if gh auth status &>/dev/null 2>&1; then
            echo "gh CLI で SSH 公開鍵を GitHub に登録しますか？ [y/N]: "
            read -r REGISTER_KEY < /dev/tty
            if [[ "$REGISTER_KEY" =~ ^[Yy]$ ]]; then
                KEY_TITLE="$(hostname)-$(date +%Y%m%d)"
                gh ssh-key add "${SSH_KEY}.pub" --title "$KEY_TITLE" \
                    && echo "SSH キーを GitHub に登録しました (タイトル: $KEY_TITLE)" \
                    || echo "登録に失敗しました (既に登録済みの可能性があります)。"
            fi
        else
            echo "GitHub CLI でログインしますか？ログイン後に SSH キーを自動登録できます。 [y/N]: "
            read -r DO_LOGIN < /dev/tty
            if [[ "$DO_LOGIN" =~ ^[Yy]$ ]]; then
                gh auth login
                # ログイン成功後にキーを登録
                if gh auth status &>/dev/null 2>&1; then
                    KEY_TITLE="$(hostname)-$(date +%Y%m%d)"
                    gh ssh-key add "${SSH_KEY}.pub" --title "$KEY_TITLE" \
                        && echo "SSH キーを GitHub に登録しました (タイトル: $KEY_TITLE)" \
                        || true
                fi
            else
                echo "手動で以下の公開鍵を GitHub に追加してください:"
                echo "  https://github.com/settings/ssh/new"
            fi
        fi
    else
        echo "手動で以下の公開鍵を GitHub に追加してください:"
        echo "  https://github.com/settings/ssh/new"
    fi

    # SSH 接続テスト
    echo ""
    printf "GitHub への SSH 接続テストを行いますか？ [y/N]: "
    read -r DO_SSH_TEST < /dev/tty
    if [[ "$DO_SSH_TEST" =~ ^[Yy]$ ]]; then
        ssh -T git@github.com 2>&1 || true
    fi
}

# ----------------------------------------
# サブコマンド: prezto
# ----------------------------------------
setup_prezto() {
    echo ""
    echo "=== Prezto セットアップ ==="

    ZPREZTO_DIR="${ZDOTDIR:-$HOME}/.zprezto"
    if [ ! -d "$ZPREZTO_DIR" ]; then
        echo "Preztoをインストール..."
        git clone --recursive https://github.com/sorin-ionescu/prezto.git "$ZPREZTO_DIR"
    else
        echo "Preztoは既にインストールされています。"
    fi
}

# ----------------------------------------
# サブコマンド: link
# ----------------------------------------
setup_link() {
    echo ""
    echo "=== シンボリックリンク作成 ==="

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
}

# ----------------------------------------
# サブコマンド: mise
# ----------------------------------------
setup_mise() {
    echo ""
    echo "=== mise セットアップ ==="

    if [ "$OS_TYPE" != "Darwin" ]; then
        echo "スキップ: mise セットアップは macOS のみ対応しています。"
        return
    fi

    if ! command -v mise &> /dev/null; then
        echo "スキップ: mise が見つかりません (Homebrew のセットアップを確認してください)。"
        return
    fi

    echo "mise でランタイムをインストール..."

    # GitHub API レート制限回避: gh CLI からトークンを取得して設定
    if [ -z "${GITHUB_TOKEN:-}" ] && command -v gh &>/dev/null; then
        if gh auth status &>/dev/null 2>&1; then
            export GITHUB_TOKEN="$(gh auth token 2>/dev/null)"
            echo "GITHUB_TOKEN を gh CLI から取得しました。"
        else
            echo ""
            echo "⚠️  GITHUB_TOKEN が未設定です。"
            echo "   mise が GitHub API にアクセスする際にレート制限に引っかかる場合があります。"
            echo "   事前に gh auth login を実行するか、以下で手動設定してください:"
            echo "   https://github.com/settings/tokens (スコープ不要)"
            echo ""
            printf "続行しますか？ [y/N]: "
            read -r CONTINUE_MISE < /dev/tty
            if [[ ! "$CONTINUE_MISE" =~ ^[Yy]$ ]]; then
                echo "スキップ: mise install を後で手動で実行してください。"
                echo "  GITHUB_TOKEN=\$(gh auth token) mise install"
                return
            fi
        fi
    fi

    # シンボリックリンク作成後なので ~/.config/mise/config.toml が有効
    if ! mise install; then
        echo ""
        echo "⚠️  mise install が失敗しました。"
        echo "   GitHub のレート制限が原因の場合は、しばらく待ってから以下を実行してください:"
        echo "   GITHUB_TOKEN=\$(gh auth token) mise install"
    fi
}

# ----------------------------------------
# サブコマンド: macos
# ----------------------------------------
setup_macos() {
    echo ""
    echo "=== macOS 固有設定 ==="

    if [ "$OS_TYPE" != "Darwin" ]; then
        echo "スキップ: macOS 固有設定は macOS のみ対応しています。"
        return
    fi

    source "$SCRIPT_DIR/macos_defaults.sh"
}

# ----------------------------------------
# サブコマンド: nvim
# ----------------------------------------
setup_nvim() {
    echo ""
    echo "=== Neovim セットアップ ==="

    # config/nvim → ~/.config/nvim のシンボリックリンク作成
    if [ -d "$DOTFILES_DIR/config/nvim" ]; then
        mkdir -p "$HOME/.config"
        link_file "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
    else
        echo "スキップ: config/nvim ディレクトリが見つかりません。"
        return
    fi

    # Neovim が利用可能ならプラグイン同期
    if command -v nvim &> /dev/null; then
        echo "Neovim プラグインを同期中..."
        nvim --headless "+Lazy! sync" +qa
        echo "プラグイン同期が完了しました。"
    else
        echo "スキップ: nvim が見つかりません (mise または Homebrew でインストールしてください)。"
    fi
}

# ----------------------------------------
# 全実行
# ----------------------------------------
setup_all() {
    setup_brew
    setup_git
    setup_ssh
    setup_prezto
    setup_link
    setup_mise
    setup_macos
}

# ----------------------------------------
# メイン: サブコマンドディスパッチ
# ----------------------------------------
echo "セットアップを開始"
echo "dotfiles location: $DOTFILES_DIR"
echo "OS: $OS_TYPE"

case "${1:-all}" in
    brew)   setup_brew ;;
    git)    setup_git ;;
    ssh)    setup_ssh ;;
    prezto) setup_prezto ;;
    link)   setup_link ;;
    mise)   setup_mise ;;
    macos)  setup_macos ;;
    nvim)   setup_nvim ;;
    all)    setup_all ;;
    help|-h|--help) show_help ;;
    *)      echo "不明なコマンド: $1"; show_help; exit 1 ;;
esac

echo ""
echo "Done！"
