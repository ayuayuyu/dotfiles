#!/usr/bin/env bash
# =============================================================================
# WezTerm 一発セットアップ (Nix 不要)
#
# やること:
#   1. Homebrew, eza, starship, bat, fzf, zoxide, zsh プラグイン, Nerd Font
#   2. ~/.zshrc.terminal (履歴・エイリアス・starship 初期化) を生成
#   3. WezTerm 本体をインストール
#   4. ~/.config/wezterm/ を dotfiles のものへシンボリックリンク
#
# 使い方:
#   bash ~/dotfiles/bin/setup-wezterm.sh
# =============================================================================

set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export DOTFILES_DIR

# shellcheck disable=SC1091
source "$DOTFILES_DIR/bin/lib/terminal-common.sh"

log "WezTerm セットアップ開始"

terminal_common_run

# --- WezTerm 本体 ---
brew_install_cask wezterm

# --- 設定ファイル ---
log "WezTerm 設定を配置"
mkdir -p "$HOME/.config"
backup_if_exists "$HOME/.config/wezterm"
ln -s "$DOTFILES_DIR/config/wezterm" "$HOME/.config/wezterm"
ok "~/.config/wezterm → $DOTFILES_DIR/config/wezterm"

ok "WezTerm セットアップ完了"
echo ""
echo "次にやること:"
echo "  1. ターミナルを再起動 (または: exec zsh)"
echo "  2. WezTerm を起動: open -a WezTerm"
