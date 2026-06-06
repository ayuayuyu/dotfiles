#!/usr/bin/env bash
# =============================================================================
# ターミナル共通セットアップ (Nix 不要)
#
# 提供するもの:
#   - Hack Nerd Font (eza のアイコン表示用)
#   - eza / bat / fzf / zoxide / starship  (CLI ツール)
#   - zsh プラグイン (syntax-highlighting / autosuggestions / history-substring-search)
#   - ~/.zshrc.terminal  (履歴・エイリアス・プラグイン読み込み・starship)
#   - ~/.config/starship.toml
#
# 使い方: setup-ghostty.sh / setup-wezterm.sh から source して terminal_common_run を呼ぶ
# =============================================================================

set -eu

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
TS="$(date +%Y%m%d-%H%M%S)"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
ok()   { printf '\033[1;32m✓\033[0m  %s\n' "$*"; }
err()  { printf '\033[1;31mxx\033[0m  %s\n' "$*" >&2; }

# ---------------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------------
warn_if_nix_managed() {
  # nix-darwin / home-manager が稼働中なら、フォールバックは設定を上書きする旨を警告する
  if command -v darwin-rebuild &>/dev/null || command -v home-manager &>/dev/null; then
    warn "nix-darwin / home-manager が検出されました。"
    warn "このスクリプトは Nix が管理する ~/.zshrc / ~/.config/* と衝突します。"
    warn "Nix 構成を使う場合は本スクリプトではなく 'bin/bootstrap.sh' を実行してください。"
    # TTY が無い (curl | bash や CI) 環境では確認できないので中止する
    if [ ! -r /dev/tty ]; then
      err "TTY が利用できないため確認できません。中止します"
      exit 1
    fi
    printf "それでも続行しますか? [y/N]: "
    read -r answer </dev/tty
    case "$answer" in
      [yY]|[yY][eE][sS]) ok "続行します" ;;
      *) err "中止しました"; exit 1 ;;
    esac
  fi
}

ensure_homebrew() {
  if command -v brew &>/dev/null; then
    ok "Homebrew は既にインストール済み"
    return
  fi
  if [[ "$(uname -s)" != "Darwin" ]]; then
    err "このスクリプトは macOS 専用です (Homebrew が必要)"
    exit 1
  fi
  log "Homebrew をインストール"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

brew_install() {
  local pkg="$1"
  if brew list --formula "$pkg" &>/dev/null; then
    ok "$pkg は既にインストール済み"
  else
    log "brew install $pkg"
    brew install "$pkg"
  fi
}

brew_install_cask() {
  local cask="$1"
  if brew list --cask "$cask" &>/dev/null; then
    ok "$cask は既にインストール済み"
  else
    log "brew install --cask $cask"
    brew install --cask "$cask"
  fi
}

# ---------------------------------------------------------------------------
# CLI ツール & プラグイン
# ---------------------------------------------------------------------------
install_cli_tools() {
  log "CLI ツールをインストール"
  brew_install eza
  brew_install bat
  brew_install fzf
  brew_install zoxide
  brew_install starship
  # tmux: Ghostty / WezTerm の keybind が tmux 前提のため必須
  brew_install tmux

  # zsh プラグイン
  brew_install zsh-syntax-highlighting
  brew_install zsh-autosuggestions
  brew_install zsh-history-substring-search
}

install_nerd_font() {
  log "Hack Nerd Font をインストール"
  brew_install_cask font-hack-nerd-font
}

# ---------------------------------------------------------------------------
# 設定ファイル配置
# ---------------------------------------------------------------------------
backup_if_exists() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mv "$target" "${target}.bak.${TS}"
    warn "既存ファイルを退避: ${target}.bak.${TS}"
  elif [[ -L "$target" ]]; then
    rm -f "$target"
  fi
}

link_starship() {
  log "starship.toml を配置"
  mkdir -p "$HOME/.config"
  backup_if_exists "$HOME/.config/starship.toml"
  ln -s "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
  ok "~/.config/starship.toml → $DOTFILES_DIR/config/starship.toml"
}

link_tmux_conf() {
  log "tmux.conf を配置"
  mkdir -p "$HOME/.config/tmux"
  backup_if_exists "$HOME/.config/tmux/tmux.conf"
  ln -s "$DOTFILES_DIR/config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
  ok "~/.config/tmux/tmux.conf → $DOTFILES_DIR/config/tmux/tmux.conf"
}

# ---------------------------------------------------------------------------
# ~/.zshrc.terminal を生成
#   - 履歴設定
#   - エイリアス (eza, bat)
#   - プラグイン読み込み (brew で入れた zsh プラグイン)
#   - starship / zoxide / fzf 初期化
# ---------------------------------------------------------------------------
write_zshrc_terminal() {
  local target="$HOME/.zshrc.terminal"
  log "$target を生成"
  cat >"$target" <<'EOF'
# =============================================================================
# ~/.zshrc.terminal  (terminal-common.sh が生成)
# =============================================================================

# Homebrew shellenv
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# --- 履歴 ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY EXTENDED_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE INC_APPEND_HISTORY HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS HIST_FIND_NO_DUPS

# --- ディレクトリ ---
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT PUSHD_TO_HOME
setopt INTERACTIVE_COMMENTS COMBINING_CHARS NO_BEEP

# --- エイリアス (eza でアイコン表示) ---
alias ls='eza --icons'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --icons --level=2'
alias cat='bat --paging=never'

# --- zsh プラグイン (Homebrew インストール分) ---
HB_PREFIX="$(brew --prefix 2>/dev/null)"
if [[ -n "$HB_PREFIX" ]]; then
  # syntax highlighting
  [[ -f "$HB_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] \
    && source "$HB_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  # autosuggestions
  [[ -f "$HB_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] \
    && source "$HB_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  # history-substring-search
  [[ -f "$HB_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ]] \
    && source "$HB_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

# --- 補完 ---
autoload -Uz compinit && compinit

# --- starship ---
command -v starship &>/dev/null && eval "$(starship init zsh)"

# --- zoxide (cd 強化) ---
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# --- fzf ---
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# --- ローカル設定 ---
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
EOF
  ok "$target を生成"
}

# ~/.zshrc から source されるようにする
ensure_zshrc_sources_terminal() {
  local zshrc="$HOME/.zshrc"
  local marker='source "$HOME/.zshrc.terminal"'
  touch "$zshrc"
  if grep -Fq "$marker" "$zshrc"; then
    ok "~/.zshrc は既に ~/.zshrc.terminal を source している"
    return
  fi
  log "~/.zshrc に source 行を追加"
  {
    echo ""
    echo "# --- dotfiles terminal setup ---"
    echo "[[ -f \"\$HOME/.zshrc.terminal\" ]] && $marker"
  } >>"$zshrc"
}

# ---------------------------------------------------------------------------
# 公開エントリポイント
# ---------------------------------------------------------------------------
terminal_common_run() {
  warn_if_nix_managed
  ensure_homebrew
  install_cli_tools
  install_nerd_font
  link_starship
  link_tmux_conf
  write_zshrc_terminal
  ensure_zshrc_sources_terminal
  ok "ターミナル共通セットアップ完了"
}
