{ ... }:

{
  programs.git = {
    enable = true;
    # user.name / user.email はマシンごとに異なるため ~/.gitconfig.local に書く。
    # 例:
    #   [user]
    #       name = ayuayuyu
    #       email = umaminokiami@gmail.com
    includes = [
      { path = "~/.gitconfig.local"; }
    ];

    settings = {
      core.editor = "nvim";

      diff.tool = "nvimdiff";
      "difftool \"nvimdiff\"".cmd = ''nvim -d "$LOCAL" "$REMOTE"'';

      merge.tool = "nvimdiff";
      "mergetool \"nvimdiff\"".cmd = ''nvim -d "$LOCAL" "$REMOTE" "$MERGED" -c '$wincmd w' -c 'wincmd J' '';
      mergetool.keepBackup = false;
    };

    ignores = [
      # macOS
      ".DS_Store"
      ".DS_Store?"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      ".fseventsd"
      "Icon?"

      # エディタ / IDE
      "*.swp"
      "*.swo"
      "*~"
      ".netrwhist"
      "Session.vim"
      ".vscode/"
      "*.code-workspace"
      ".idea/"
      "*.iml"
      "*.iws"
      "*.ipr"

      # 秘密情報
      ".env"
      ".env.local"
      ".env.*.local"
      ".envrc"
      "*.pem"
      "*.key"
      "*.pfx"
      "*.p12"
      "*.crt"
      "*.cer"
      "id_rsa"
      "id_rsa.pub"
      "id_ed25519"
      "id_ed25519.pub"
      "secrets.json"
      "credentials.json"
      "service-account.json"

      # ログ・キャッシュ
      "*.log"
      "*.tmp"
      "*.bak"
      "*.orig"
      ".cache/"
      ".temp/"

      # OS
      "Thumbs.db"
      "ehthumbs.db"
      "Desktop.ini"
      "$RECYCLE.BIN/"
      ".Trash-*/"

      # Node.js
      "node_modules/"
      "npm-debug.log*"
      "yarn-debug.log*"
      "yarn-error.log*"
      ".pnpm-debug.log*"
      ".npm/"
      ".yarn/cache"
      ".yarn/unplugged"
      ".yarn/build-state.yml"
      "dist/"
      ".next/"
      ".nuxt/"
      ".output/"

      # Python
      "__pycache__/"
      "*.py[cod]"
      "*.pyo"
      "*.pyd"
      ".Python"
      ".venv/"
      "venv/"
      "env/"
      "*.egg-info/"
      ".eggs/"
      "build/"
      "*.whl"
      ".mypy_cache/"
      ".ruff_cache/"
      ".pytest_cache/"

      # Rust
      "target/"
      "Cargo.lock.bak"

      # Go
      "vendor/"

      # Bun
      ".bun/"

      # ビルド成果物
      "*.o"
      "*.a"
      "*.so"
      "*.dylib"
      "*.exe"
      "*.out"
    ];
  };
}
