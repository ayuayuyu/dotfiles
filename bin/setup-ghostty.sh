#!/usr/bin/env bash
# =============================================================================
# Ghostty 一発セットアップ (Nix 不要)
#
# やること:
#   1. Homebrew, eza, starship, bat, fzf, zoxide, zsh プラグイン, Nerd Font
#   2. ~/.zshrc.terminal (履歴・エイリアス・starship 初期化) を生成
#   3. Ghostty 本体をインストール
#   4. ~/.config/ghostty/config を dotfiles のものへシンボリックリンク
#
# 使い方:
#   bash ~/dotfiles/bin/setup-ghostty.sh
# =============================================================================

set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export DOTFILES_DIR

# shellcheck disable=SC1091
source "$DOTFILES_DIR/bin/lib/terminal-common.sh"

log "Ghostty セットアップ開始"

terminal_common_run

# --- Ghostty 本体 ---
brew_install_cask ghostty

# --- 設定ファイル ---
log "Ghostty 設定を配置"
mkdir -p "$HOME/.config/ghostty"
backup_if_exists "$HOME/.config/ghostty/config"
ln -s "$DOTFILES_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"
ok "~/.config/ghostty/config → $DOTFILES_DIR/config/ghostty/config"

ok "Ghostty セットアップ完了"
echo ""
echo "次にやること:"
echo "  1. ターミナルを再起動 (または: exec zsh)"
echo "  2. Ghostty を起動: open -a Ghostty"
echo "  3. Cmd+\` で Quick Terminal をトグル"
