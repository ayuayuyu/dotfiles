# Nix ガイド

このドキュメントでは、本 dotfiles で使用している Nix の基本概念と使い方を解説する。

---

## 目次

1. [Nix とは](#nix-とは)
2. [Nix の基本概念](#nix-の基本概念)
3. [Nix Flakes](#nix-flakes)
4. [nix-darwin](#nix-darwin)
5. [home-manager](#home-manager)
6. [本リポジトリの構成](#本リポジトリの構成)
7. [日常的な使い方](#日常的な使い方)
8. [よく使うコマンド](#よく使うコマンド)
9. [トラブルシューティング](#トラブルシューティング)

---

## Nix とは

Nix は**宣言的パッケージマネージャ**であり、以下の特徴を持つ。

- **再現性**: 同じ設定ファイルから、いつでも同じ環境を構築できる
- **アトミック**: 変更の適用は全か無。途中で失敗しても環境が壊れない
- **ロールバック**: 過去の世代にいつでも戻せる
- **分離**: パッケージ同士が干渉しない。異なるバージョンの共存が可能

### Homebrew との違い

| | Homebrew | Nix |
|---|---|---|
| 管理方式 | 命令的 (`brew install X`) | 宣言的 (設定ファイルに書く) |
| 再現性 | Brewfile で部分的に可能 | flake.lock で完全に再現可能 |
| ロールバック | 不可 | 任意の世代に戻せる |
| クロスプラットフォーム | macOS + Linux (制限あり) | macOS + Linux + NixOS |
| パッケージ数 | ~7,000 formulae | ~100,000+ packages (nixpkgs) |
| 依存関係の分離 | グローバルに共有 | ハッシュベースで完全分離 |

---

## Nix の基本概念

### Nix 言語

Nix は独自の純粋関数型言語を持つ。JSON に似ているが、関数・変数束縛・遅延評価がある。

```nix
# 基本的な型
"文字列"                    # 文字列
42                          # 整数
true                        # 真偽値
[ 1 2 3 ]                   # リスト
{ key = "value"; }          # アトリビュートセット (オブジェクト)

# 関数
x: x + 1                   # 無名関数
{ a, b }: a + b             # パターンマッチ引数

# let 束縛
let
  name = "world";
in
  "hello ${name}"           # => "hello world"

# 条件分岐
if condition then "yes" else "no"

# with 式 (スコープにアトリビュートを展開)
with pkgs; [ git neovim ]   # pkgs.git, pkgs.neovim と同じ

# inherit (親スコープから変数を引き継ぐ)
{ inherit username; }       # { username = username; } と同じ
```

### Nix Store

すべてのパッケージは `/nix/store/` 以下にハッシュ付きのパスで保存される。

```
/nix/store/abc123...-neovim-0.10.0/
/nix/store/def456...-git-2.44.0/
```

- 同じ入力からは常に同じハッシュが生成される (再現性)
- パッケージ同士は互いに干渉しない (分離)
- 使われなくなったパッケージは `nix-collect-garbage` で削除できる

### Derivation

Nix におけるビルドの最小単位。「この入力からこの出力を作る」という宣言。
nixpkgs のパッケージはすべて derivation として定義されている。

### Profile と世代

Nix はパッケージのセットを「プロファイル」として管理し、変更のたびに新しい「世代」を作る。
任意の世代にロールバックできるため、アップデートで環境が壊れても安全。

```bash
# 世代一覧
nix profile history

# ロールバック
# nix-darwin の場合
darwin-rebuild switch --rollback
```

---

## Nix Flakes

Flakes は Nix の**プロジェクト管理機能**。`flake.nix` と `flake.lock` の2ファイルで構成される。

### flake.nix

プロジェクトのエントリーポイント。`inputs` (依存関係) と `outputs` (成果物) を定義する。

```nix
{
  # inputs: このプロジェクトが依存する外部 flake
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
  };

  # outputs: このプロジェクトが提供するもの
  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }: {
    darwinConfigurations."hostname" = nix-darwin.lib.darwinSystem { ... };
    homeConfigurations."username" = home-manager.lib.homeManagerConfiguration { ... };
  };
}
```

### flake.lock

依存関係の正確なバージョン (コミットハッシュ) を記録するロックファイル。
これにより、いつ・どこでビルドしても同じ結果が得られる。

```bash
# 依存関係の更新
nix flake update              # 全 inputs を最新に更新
nix flake update nixpkgs      # nixpkgs のみ更新

# ロックファイルの確認
nix flake metadata
```

### `follows`

依存関係の nixpkgs バージョンを統一するための仕組み。

```nix
nix-darwin = {
  url = "github:LnL7/nix-darwin";
  inputs.nixpkgs.follows = "nixpkgs";  # nix-darwin の nixpkgs を自分と同じにする
};
```

これにより、nix-darwin と home-manager が同じ nixpkgs を参照し、パッケージの重複ダウンロードを防ぐ。

---

## nix-darwin

nix-darwin は **macOS のシステム設定を Nix で宣言的に管理**するツール。NixOS の macOS 版に近い。

### できること

- パッケージのインストール
- macOS のシステム設定 (`defaults write` 相当)
- Homebrew cask の宣言的管理
- サービスの管理
- Touch ID for sudo
- zsh のシステムレベル有効化

### system.defaults

macOS の `defaults write` コマンドを宣言的に記述できる。

```nix
system.defaults = {
  # スクロール方向
  NSGlobalDomain."com.apple.swipescrolldirection" = true;

  # Dock
  dock = {
    autohide = true;
    show-recents = false;
    tilesize = 48;
  };

  # Finder
  finder = {
    AppleShowAllExtensions = true;
    FXEnableExtensionChangeWarning = false;
    ShowPathbar = true;
  };

  # トラックパッド
  trackpad = {
    Clicking = true;  # タップでクリック
    TrackpadRightClick = true;
  };
};
```

利用可能なオプションは以下で確認できる。

```bash
# nix-darwin のオプション検索
man 5 configuration.nix  # nix-darwin をインストール後
# または https://daiderd.com/nix-darwin/manual/index.html
```

### Homebrew 統合

nix-darwin は Homebrew を直接管理できる。nixpkgs に存在しない macOS GUI アプリに使う。

```nix
homebrew = {
  enable = true;
  onActivation = {
    autoUpdate = true;
    cleanup = "zap";   # 宣言にないアプリを削除
  };
  casks = [
    "ghostty"
    "docker-desktop"
    "raycast"
  ];
};
```

`cleanup = "zap"` にすると、`casks` リストから削除したアプリは次回の `darwin-rebuild switch` で自動的にアンインストールされる。

---

## home-manager

home-manager は**ユーザーレベルの設定を Nix で宣言的に管理**するツール。

### できること

- ユーザーパッケージのインストール (`home.packages`)
- dotfiles の配置 (`home.file`, `xdg.configFile`)
- アプリケーション固有の設定 (`programs.*`)

### 使い方: スタンドアロン vs モジュール

| 方式 | 用途 | 適用コマンド |
|---|---|---|
| **モジュール** | nix-darwin/NixOS に組み込み | `darwin-rebuild switch` |
| **スタンドアロン** | Nix のみインストールされた環境 | `home-manager switch` |

本リポジトリでは macOS はモジュール方式、Linux はスタンドアロン方式を使用。

### programs.*

多くのツールに専用モジュールがあり、設定を Nix の構文で記述できる。
`programs.*.enable = true` とするだけでパッケージのインストールとシェル統合が自動的に行われるため、
`home.packages` に手動で追加したり `initExtra` で `eval "$(tool init zsh)"` する必要がない。

```nix
# Git の例
programs.git = {
  enable = true;
  userName = "your name";
  userEmail = "your@email.com";
  extraConfig = {
    core.editor = "nvim";
    merge.tool = "nvimdiff";
  };
  ignores = [ ".DS_Store" "*.swp" ];
};

# zsh の例
programs.zsh = {
  enable = true;
  autosuggestion.enable = true;
  syntaxHighlighting.enable = true;
  shellAliases = {
    vi = "nvim";
    ls = "eza --icons";
  };
};

# tmux の例
programs.tmux = {
  enable = true;
  mouse = true;
  keyMode = "vi";
  plugins = with pkgs.tmuxPlugins; [ resurrect continuum ];
};

# ツール統合の例 (enable するだけで zsh init が自動挿入される)
programs.starship = { enable = true; enableZshIntegration = true; };
programs.zoxide   = { enable = true; enableZshIntegration = true; };
programs.fzf      = { enable = true; enableZshIntegration = true; };
programs.mise     = { enable = true; enableZshIntegration = true; };
```

#### `programs.*` vs `home.packages` + 手動 init の使い分け

| 方法 | いつ使うか |
|---|---|
| `programs.X.enable = true` | home-manager に専用モジュールがある場合 (推奨) |
| `home.packages` に追加 | モジュールがないツール、または単にバイナリが欲しい場合 |
| `initExtra` で `eval "$(X init zsh)"` | home-manager にモジュールがなく、シェル統合が必要な場合 |

`programs.*` を使うメリット:
- パッケージのインストール + シェル統合 + 設定を一箇所で管理できる
- `initExtra` でのシェルスクリプト量が減り、設定が壊れにくくなる
- Nix の型チェックにより設定ミスをビルド時に検出できる

利用可能な programs は [home-manager のオプション一覧](https://nix-community.github.io/home-manager/options.xhtml) で確認できる。

### home.file / xdg.configFile

既存の設定ファイルをそのまま配置する場合に使う。

```nix
# ~/.config/ghostty/config に配置
xdg.configFile."ghostty/config".source = ./config/ghostty/config;

# テキストを直接記述
home.file.".bashrc".text = ''
  export PATH="$HOME/.local/bin:$PATH"
'';
```

### mkOutOfStoreSymlink

通常、`source` で指定したファイルは Nix Store にコピーされ、read-only になる。
書き込みが必要なファイル (例: `lazy-lock.json`) は `mkOutOfStoreSymlink` を使う。

```nix
# Nix Store を経由せず、直接リポジトリへのシンボリックリンクを作成
xdg.configFile."nvim".source =
  config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/config/nvim";
```

**使い分け:**

| 方式 | 用途 |
|---|---|
| `source = ./path` | 読み取り専用でよい設定ファイル |
| `mkOutOfStoreSymlink` | アプリが書き込むファイル (nvim, wireshark 等) |
| `programs.*` | 専用モジュールがあるツール (git, zsh, tmux 等) |

---

## 本リポジトリの構成

```
dotfiles/
├── flake.nix                 # エントリーポイント
├── flake.lock                # 依存バージョンのロック
│
├── hosts/
│   ├── darwin/               # macOS 固有
│   │   ├── default.nix       #   nix-darwin 基本設定
│   │   ├── homebrew.nix      #   GUI アプリ (cask)
│   │   └── system.nix        #   macOS defaults
│   └── linux/                # Linux 固有
│       └── default.nix
│
├── home/                     # 共通 (home-manager)
│   ├── default.nix           #   エントリーポイント + xdg.configFile
│   ├── packages.nix          #   CLI パッケージ一覧
│   ├── shell/
│   │   ├── zsh.nix           #   zsh 設定
│   │   └── starship.nix      #   Starship プロンプト
│   ├── git.nix               #   Git 設定
│   ├── tmux.nix              #   tmux 設定
│   └── ssh.nix               #   SSH 設定
│
├── config/                   # raw 設定ファイル群
│   ├── nvim/                 #   Neovim (Lua)
│   ├── ghostty/config        #   Ghostty
│   ├── starship.toml         #   Starship
│   ├── tmux/tmux.conf        #   tmux (参照用、管理は tmux.nix)
│   ├── mise/config.toml      #   mise ランタイム
│   └── wezterm/              #   WezTerm (Lua)
│
├── scripts/                  # tmux レイアウトスクリプト
└── bin/
    └── bootstrap.sh          # 初回セットアップ
```

### 設定の流れ

```
flake.nix
  ├── hosts/darwin/default.nix  (nix-darwin システム設定)
  │     ├── homebrew.nix        (cask アプリ)
  │     └── system.nix          (macOS defaults)
  │
  └── home/default.nix          (home-manager ユーザー設定)
        ├── packages.nix        (CLI パッケージ: home.packages)
        ├── shell/zsh.nix       (zsh + プラグイン + エイリアス)
        │     └── programs.zoxide / fzf / mise  (ツール統合)
        ├── shell/starship.nix  (プロンプト: programs.starship)
        ├── git.nix             (Git: programs.git)
        ├── tmux.nix            (tmux: programs.tmux)
        └── ssh.nix             (SSH: programs.ssh)
```

### 設定方式の分類

本リポジトリでは、ツールの性質に応じて3つの方式を使い分けている。

| 方式 | 対象 | 理由 |
|---|---|---|
| `programs.*` | zsh, git, tmux, ssh, starship, zoxide, fzf, mise | 専用モジュールあり。設定 + パッケージ + シェル統合を一元管理 |
| `mkOutOfStoreSymlink` | nvim, ghostty, wezterm, wireshark, mise/config.toml, starship.toml | アプリが書き込む or Lua/TOML 等の生設定を直接管理したい |
| `home.packages` | bat, eza, ripgrep, fd, lazygit, neovim, tmux 等 | バイナリだけ必要。設定は別管理 |

---

## 日常的な使い方

### 設定を変更して適用する

```bash
# 1. Nix ファイルを編集
vim ~/dotfiles/home/packages.nix

# 2. 適用 (macOS)
darwin-rebuild switch --flake ~/dotfiles#ayuayuyu-mac
# エイリアス:
rebuild

# 2. 適用 (Linux)
home-manager switch --flake ~/dotfiles#ayuayuyu-linux
```

### パッケージを追加する

`home/packages.nix` にパッケージ名を追加して `rebuild` する。

```nix
home.packages = with pkgs; [
  git
  gh
  # ↓ 新しく追加
  jq
  yq
];
```

パッケージの検索は以下で行う。

```bash
nix search nixpkgs パッケージ名
# または https://search.nixos.org/packages
```

### GUI アプリを追加する (macOS)

`hosts/darwin/homebrew.nix` の `casks` に追加して `rebuild` する。

```nix
casks = [
  "ghostty"
  # ↓ 新しく追加
  "slack"
];
```

### 依存関係を更新する

```bash
# 全 inputs を最新に更新
cd ~/dotfiles
nix flake update

# 適用
rebuild
```

これにより nixpkgs が更新され、全パッケージが最新版になる。
問題があればロールバックできる。

### ロールバック

```bash
# 直前の世代に戻す
darwin-rebuild switch --rollback

# 世代一覧を見て指定
darwin-rebuild list-generations
darwin-rebuild switch --switch-generation 42
```

---

## よく使うコマンド

```bash
# === 設定の適用 ===
darwin-rebuild switch --flake ~/dotfiles#ayuayuyu-mac  # macOS
home-manager switch --flake ~/dotfiles#ayuayuyu-linux  # Linux
rebuild                                                 # エイリアス (OS 自動判定)

# === パッケージ検索 ===
nix search nixpkgs neovim           # パッケージを検索
nix search nixpkgs --json neovim    # JSON で詳細表示

# === Flake 操作 ===
nix flake update                    # 全依存を最新化
nix flake update nixpkgs            # nixpkgs のみ更新
nix flake metadata                  # 依存関係の情報表示
nix flake check                     # flake の構文チェック

# === ビルドのみ (適用しない) ===
darwin-rebuild build --flake ~/dotfiles#ayuayuyu-mac

# === ロールバック ===
darwin-rebuild switch --rollback
darwin-rebuild list-generations

# === ガベージコレクション ===
nix-collect-garbage                 # 未使用パッケージを削除
nix-collect-garbage -d              # 古い世代も含めて削除
nix store gc                        # Nix Store のクリーンアップ

# === デバッグ ===
nix repl                            # Nix 言語の REPL
nix eval .#darwinConfigurations.ayuayuyu-mac.config.system.build.toplevel
                                    # 評価のみ (デバッグ用)
```

---

## トラブルシューティング

### `darwin-rebuild` が見つからない

初回ビルド時は `nix run nix-darwin -- switch` を使う。
一度適用すれば `darwin-rebuild` コマンドが利用可能になる。

```bash
nix run nix-darwin -- switch --flake ~/dotfiles#ayuayuyu-mac
```

### ビルドエラー: パッケージが見つからない

nixpkgs のパッケージ名は Homebrew と異なる場合がある。

```bash
# 正しい名前を検索
nix search nixpkgs キーワード
```

### `collision between` エラー

2つのパッケージが同じファイルを提供している場合に発生する。
`home.packages` でどちらかを除外するか、`priority` を設定する。

```nix
home.packages = [
  (pkgs.lib.lowPrio pkgs.coreutils)  # 優先度を下げる
];
```

### home-manager と nix-darwin のファイル衝突

既に `~/.zshrc` 等が存在する場合、home-manager が上書きできずエラーになる。
既存ファイルをバックアップして削除する。

```bash
mv ~/.zshrc ~/.zshrc.bak
mv ~/.zprofile ~/.zprofile.bak
rebuild
```

### Nix Store がディスクを圧迫する

```bash
# 古い世代を削除してからガベージコレクション
nix-collect-garbage -d

# 特定の日数より古い世代のみ削除
nix-collect-garbage --delete-older-than 30d
```

### flake.lock を更新したら壊れた

```bash
# flake.lock を前のコミットに戻す
git checkout HEAD~1 -- flake.lock
rebuild
```

---

## 参考リンク

- [Nix 公式マニュアル](https://nix.dev/)
- [nixpkgs パッケージ検索](https://search.nixos.org/packages)
- [nix-darwin オプション一覧](https://daiderd.com/nix-darwin/manual/index.html)
- [home-manager オプション一覧](https://nix-community.github.io/home-manager/options.xhtml)
- [Nix 言語チュートリアル](https://nix.dev/tutorials/nix-language)
- [Zero to Nix](https://zero-to-nix.com/) - 初心者向けガイド
