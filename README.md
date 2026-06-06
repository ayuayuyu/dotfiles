# dotfiles

Nix Flakes + nix-darwin + home-manager で管理する macOS / Linux 両対応の dotfiles。

## 構成

```
.
├── flake.nix              # エントリポイント (nixpkgs / nix-darwin / home-manager)
├── flake.lock
├── bin/
│   ├── bootstrap.sh       # 新規マシン用 Nix + nix-darwin セットアップ
│   ├── setup-ghostty.sh   # Nix 不要の Ghostty フォールバックセットアップ
│   ├── setup-wezterm.sh   # Nix 不要の WezTerm フォールバックセットアップ
│   └── lib/               # 上記スクリプトの共通関数
├── hosts/
│   ├── darwin/            # macOS: nix-darwin 設定 + Homebrew cask + system defaults
│   └── linux/             # Linux: home-manager standalone
├── home/                  # 共有 home-manager モジュール
│   ├── default.nix        # xdg.configFile / imports
│   ├── packages.nix       # CLI パッケージ (nixpkgs)
│   ├── git.nix
│   ├── ssh.nix
│   ├── tmux.nix
│   └── shell/
│       ├── zsh.nix        # zsh + プラグイン
│       └── starship.nix
└── config/                # 生で symlink される設定 (mkOutOfStoreSymlink)
    ├── nvim/              # Neovim (lazy.nvim + Mason)
    ├── ghostty/
    ├── tmux/              # tmux.conf (Nix とフォールバック両方から参照)
    ├── mise/              # 各言語ランタイムバージョン
    ├── starship.toml
    ├── git/
    ├── raycast/
    └── wireshark/
```

詳細な Nix の使い方は [`docs/nix.md`](docs/nix.md) を参照。

## セットアップ

### 新規 macOS

```sh
# 1. リポジトリ取得
git clone https://github.com/ayuayuyu/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Nix + nix-darwin インストール
bash bin/bootstrap.sh

# 3. 適用
darwin-rebuild switch --flake ~/dotfiles#ayuayuyu-mac
```

### 新規 Linux

```sh
git clone https://github.com/ayuayuyu/dotfiles.git ~/dotfiles
nix run home-manager/master -- switch --flake ~/dotfiles#ayuayuyu-linux
```

### Nix を使わない場合 (フォールバック)

Ghostty 単体だけ欲しい場合:

```sh
bash ~/dotfiles/bin/setup-ghostty.sh
```

> ⚠️ **Nix 構成と排他**: `bin/setup-*.sh` は Homebrew で CLI を入れ `~/.zshrc` と `~/.config/*` を直接書き換えます。`bin/bootstrap.sh` (Nix 経路) と併用しないでください。検出時は確認プロンプトが出ます。

## 日常運用

| 操作 | コマンド |
| --- | --- |
| 設定を反映 (macOS) | `rebuild` (= `darwin-rebuild switch --flake ~/dotfiles#ayuayuyu-mac`) |
| 設定を反映 (Linux) | `rebuild` (= `home-manager switch --flake ~/dotfiles#ayuayuyu-linux`) |
| 依存を最新化 | `nix flake update` |
| 構成検証 | `nix flake check` |
| 過去世代 | `darwin-rebuild --list-generations` |
| ロールバック | `darwin-rebuild rollback` |

`rebuild` alias は `home/shell/zsh.nix` で OS 自動分岐する。

## ローカル個別設定

リポジトリ管理外で、マシン固有の設定はこちら:

- `~/.zshrc.local` - ローカル専用シェル設定
- `~/.ssh/config.local` - 内部ホスト用 SSH 設定
- `~/.gitconfig.local` - git の user.name / user.email 等

## アーキテクチャメモ

- **パッケージ管理**: CLI = nixpkgs / GUI = Homebrew cask (`hosts/darwin/homebrew.nix`)
  - GUI アプリは必ず `hosts/darwin/homebrew.nix` の `casks` に追加する。`cleanup = "zap"` のため、宣言外の cask は次回 rebuild で削除される。
- **シェルプラグイン**: home-manager の `programs.zsh` 内蔵 (sheldon は撤廃)
- **ランタイム**: `mise` (Nix 化せず維持) - Node / Go / Rust / Bun / pnpm / Python
- **Neovim**: lazy.nvim + Mason (生 Lua, Nix 化せず)
- **tmux**: 基本設定は `config/tmux/tmux.conf` を Nix とフォールバック両方で共有。Ghostty 連携の `terminal-features` 等は `home/tmux.nix` 側のみ
- **書き込み可能な設定**: `mkOutOfStoreSymlink` でリポジトリ実体へ直接シンボリックリンク
