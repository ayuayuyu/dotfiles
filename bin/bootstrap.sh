#!/bin/bash

# =============================================================================
# Nix + nix-darwin / home-manager 一発セットアップスクリプト
#
# 想定: 既に ~/dotfiles に clone 済みの状態で実行する
#   bash ~/dotfiles/bin/bootstrap.sh
# =============================================================================

set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OS_TYPE="$(uname -s)"
TS="$(date +%Y%m%d-%H%M%S)"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
ok()   { printf '\033[1;32m✓\033[0m  %s\n' "$*"; }

log "dotfiles セットアップ開始"
echo "  dotfiles: $DOTFILES_DIR"
echo "  OS:       $OS_TYPE"

# ---------------------------------------------------------------------------
# 1. Nix (Determinate Installer)
# ---------------------------------------------------------------------------
if ! command -v nix &>/dev/null; then
  log "Nix をインストール"
  curl --proto '=https' --tlsv1.2 -sSf -L \
    https://install.determinate.systems/nix | sh -s -- install --no-confirm

  # 現セッションで nix を使えるようにする
  if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    # shellcheck disable=SC1091
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
else
  ok "Nix は既にインストール済み"
fi

# experimental-features がまだ無い場合は付与（古い Nix を別途入れていた場合のフォールバック）
if ! nix --extra-experimental-features 'nix-command flakes' eval --expr '1' &>/dev/null; then
  warn "Nix の experimental-features が未設定。--extra-experimental-features で実行を継続します"
fi
NIX_FLAGS=(--extra-experimental-features 'nix-command flakes')

# ---------------------------------------------------------------------------
# 2. Homebrew (macOS のみ。GUI cask 用)
# ---------------------------------------------------------------------------
if [ "$OS_TYPE" = "Darwin" ]; then
  if ! command -v brew &>/dev/null; then
    log "Homebrew をインストール"
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if   [ -f /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ];   then eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    ok "Homebrew は既にインストール済み"
  fi
fi

# ---------------------------------------------------------------------------
# 3. home-manager と衝突する既存シンボリックリンクを退避
#    (backupFileExtension は symlink を退避できないため手動で行う)
# ---------------------------------------------------------------------------
log "既存設定ファイルの衝突を解消"
move_if_symlink() {
  local target="$1"
  if [ -L "$target" ]; then
    local backup="${target}.pre-nix-${TS}"
    mv "$target" "$backup"
    ok "symlink を退避: $target -> $backup"
  fi
}
# home-manager が書き込む可能性のあるパス
move_if_symlink "$HOME/.ssh/config"
move_if_symlink "$HOME/.zshrc"
move_if_symlink "$HOME/.zprofile"
move_if_symlink "$HOME/.zshenv"
move_if_symlink "$HOME/.gitconfig"
move_if_symlink "$HOME/.tmux.conf"

# ssh 用ディレクトリ
mkdir -p "$HOME/.ssh/sockets"
chmod 700 "$HOME/.ssh" "$HOME/.ssh/sockets"

# ---------------------------------------------------------------------------
# 4. OS 別: nix-darwin / home-manager 適用
# ---------------------------------------------------------------------------
if [ "$OS_TYPE" = "Darwin" ]; then
  log "nix-darwin で system + home を適用"
  if command -v darwin-rebuild &>/dev/null; then
    sudo darwin-rebuild switch --flake "$DOTFILES_DIR#ayuayuyu-mac"
  else
    # 初回は darwin-rebuild が無いので nix run で
    sudo nix "${NIX_FLAGS[@]}" run nix-darwin -- \
      switch --flake "$DOTFILES_DIR#ayuayuyu-mac"
  fi
elif [ "$OS_TYPE" = "Linux" ]; then
  log "home-manager を適用"
  if command -v home-manager &>/dev/null; then
    home-manager switch --flake "$DOTFILES_DIR#ayuayuyu-linux" -b "pre-nix-${TS}"
  else
    nix "${NIX_FLAGS[@]}" run home-manager -- \
      switch --flake "$DOTFILES_DIR#ayuayuyu-linux" -b "pre-nix-${TS}"
  fi
else
  warn "未対応の OS: $OS_TYPE"
  exit 1
fi

# ---------------------------------------------------------------------------
# 5. 後処理: ランタイム / プラグインの同期
# ---------------------------------------------------------------------------
# 後処理は home-manager で生成された PATH を読むためサブシェルを login で起動
run_in_login_shell() {
  # zprofile / zshrc を読んだ状態で実行
  /bin/zsh -lc "$1" || warn "失敗: $1 (手動で再実行してください)"
}

if command -v mise &>/dev/null || [ -x /etc/profiles/per-user/"$USER"/bin/mise ]; then
  log "mise: ランタイムをインストール"
  run_in_login_shell "mise install"
fi

if command -v nvim &>/dev/null || [ -x /etc/profiles/per-user/"$USER"/bin/nvim ]; then
  log "Neovim: lazy.nvim プラグインを同期"
  run_in_login_shell "nvim --headless '+Lazy! sync' +qa"
fi

# ---------------------------------------------------------------------------
# 6. 完了
# ---------------------------------------------------------------------------
echo
ok "セットアップ完了！"
echo
echo "今後の適用コマンド (alias: rebuild):"
if [ "$OS_TYPE" = "Darwin" ]; then
  echo "  darwin-rebuild switch --flake ~/dotfiles#ayuayuyu-mac"
else
  echo "  home-manager  switch --flake ~/dotfiles#ayuayuyu-linux"
fi
echo
echo "残りの手動セットアップ:"
echo "  - git ユーザー: git config --global user.name '名前' / user.email '...'"
echo "  - SSH キー:     ssh-keygen -t ed25519 -C 'email@example.com'"
echo "  - tmux プラグイン: tmux 起動後 prefix + I"
echo "  - .pre-nix-${TS} に退避したファイルがあれば内容を確認して削除"
