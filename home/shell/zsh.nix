{ pkgs, isLinux, ... }:

{
  programs.zsh = {
    enable = true;

    # --- ヒストリ設定 ---
    history = {
      size = 10000;
      save = 10000;
      path = "$HOME/.zsh_history";
      ignoreDups = true;
      ignoreAllDups = true;
      share = true;
      extended = true;
      ignoreSpace = true;
    };

    # --- シェルオプション ---
    autocd = true;
    defaultKeymap = "viins";

    # --- プラグイン (sheldon の代替) ---
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    enableCompletion = true;

    # --- 環境変数 (zprofile 相当) ---
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
      MANPAGER = "nvim +Man!";
      LANG = "en_US.UTF-8";
      LESS = "-g -i -M -R -S -w -X -z-4";
    };

    # --- initContent: zshrc の自由記述部分 ---
    initContent = ''
      # tmux 自動アタッチ (Ghostty 起動時のみ。WezTerm では使わない)
      if [[ -z "$TMUX" ]] && [[ "$TERM_PROGRAM" == "ghostty" ]] && command -v tmux &>/dev/null; then
        tmux attach -t main 2>/dev/null || tmux new -s main
      fi

      # ディレクトリオプション
      setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT PUSHD_TO_HOME
      setopt INTERACTIVE_COMMENTS COMBINING_CHARS NO_BEEP
      setopt INC_APPEND_HISTORY HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS HIST_FIND_NO_DUPS

      # 危険コマンドのハイライト (赤背景で警告)
      ZSH_HIGHLIGHT_HIGHLIGHTERS+=(pattern)
      typeset -A ZSH_HIGHLIGHT_PATTERNS
      ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')
      ZSH_HIGHLIGHT_PATTERNS+=('rm -rf' 'fg=white,bold,bg=red')
      ZSH_HIGHLIGHT_PATTERNS+=('chmod 777 *' 'fg=white,bold,bg=red')
      ZSH_HIGHLIGHT_PATTERNS+=('chmod -R 777 *' 'fg=white,bold,bg=red')

      # vi モードカーソル切替
      function zle-keymap-select {
        if [[ ''${KEYMAP} == vicmd ]]; then
          echo -ne '\e[1 q'  # ブロック
        else
          echo -ne '\e[5 q'  # ビーム
        fi
      }
      zle -N zle-keymap-select
      echo -ne '\e[5 q'

      # git clone with ssh
      function git-clone-ssh() {
        parts=(''${(@s:/:)1})
        echo git@github.com:''${(@j:/:)parts[3,4]}
        git clone git@github.com:''${(@j:/:)parts[3,4]}
      }

      # history-substring-search キーバインド
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      bindkey -M vicmd 'k' history-substring-search-up
      bindkey -M vicmd 'j' history-substring-search-down

      # SSH: TERM 修正 (xterm-ghostty はリモートで認識されないため)
      if [[ "$TERM" == "xterm-ghostty" ]]; then
        alias ssh="TERM=xterm-256color ssh"
      fi

      # PATH
      export PATH="''${HOME}/.local/bin:''${PATH}"

      # Aider + Llama 4 Scout (REDACTED_USER server)
      function aider-scout() {
        if ! lsof -i:11434 -t >/dev/null 2>&1; then
          echo "REDACTED_USER（ITS）サーバーへSSHトンネルを接続しています..."
          ssh -N -f -L 11434:localhost:11434 REDACTED_USER@REDACTED_HOST
        fi
        export OLLAMA_API_BASE=http://localhost:11434
        echo "Llama 4 Scout (Aider) を起動します..."
        aider --model ollama/yasserrmd/Llama-4-Scout-17B-16E-Instruct "$@"
      }
    '';

    # --- シェルエイリアス ---
    shellAliases = {
      vi = "nvim";
      gc = "git-clone-ssh";
      t4 = "~/dotfiles/scripts/tmux-4pane.sh";
      t6 = "~/dotfiles/scripts/tmux-6pane.sh";
      t6v = "~/dotfiles/scripts/tmux-6vpane.sh";
      t8 = "~/dotfiles/scripts/tmux-8pane.sh";
      ls = "eza --icons";
      ll = "eza -l --icons --git";
      la = "eza -la --icons --git";
      lt = "eza --tree --icons --level=2";
      cat = "bat --paging=never";

      # Nix 再ビルド
      rebuild = if isLinux
        then "home-manager switch --flake ~/dotfiles#ayuayuyu-linux"
        else "darwin-rebuild switch --flake ~/dotfiles#ayuayuyu-mac";
    };

    # --- profileExtra: zprofile 相当 ---
    profileExtra = ''
      # Homebrew PATH (cask アプリ用に残す)
      if [[ "$OSTYPE" == darwin* ]]; then
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
          eval "$(/opt/homebrew/bin/brew shellenv zsh)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
          eval "$(/usr/local/bin/brew shellenv zsh)"
        fi
      elif [[ "$OSTYPE" == linux* ]]; then
        if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
          eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
        elif [[ -f "$HOME/.linuxbrew/bin/brew" ]]; then
          eval "$($HOME/.linuxbrew/bin/brew shellenv zsh)"
        fi
      fi

      # パス重複排除
      typeset -gU cdpath fpath mailpath path

      path=(
        $HOME/{,s}bin(N)
        /opt/{homebrew,local}/{,s}bin(N)
        /home/linuxbrew/.linuxbrew/{,s}bin(N)
        $HOME/.linuxbrew/{,s}bin(N)
        /usr/local/{,s}bin(N)
        $path
      )

      # GitHub Token (mise の GitHub API レート制限回避)
      if [[ -z "$GITHUB_TOKEN" ]] && command -v gh &>/dev/null; then
        if gh auth status &>/dev/null 2>&1; then
          export GITHUB_TOKEN="$(gh auth token 2>/dev/null)"
        fi
      fi

      # Browser
      if [[ -z "$BROWSER" ]]; then
        if [[ "$OSTYPE" == darwin* ]]; then
          export BROWSER='open'
        elif [[ "$OSTYPE" == linux* ]]; then
          export BROWSER='xdg-open'
        fi
      fi

      # Less
      if [[ -z "$LESSOPEN" ]] && (( $#commands[(i)lesspipe(|.sh)] )); then
        export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
      fi
    '';
  };

  # --- ツール統合 (home-manager が zsh init を自動生成) ---
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.mise = {
    enable = true;
    enableZshIntegration = true;
  };
}
