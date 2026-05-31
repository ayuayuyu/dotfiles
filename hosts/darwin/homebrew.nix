{ ... }:

{
  # nix-darwin の Homebrew モジュール
  # CLI ツールは nixpkgs で管理、GUI アプリのみ Homebrew cask で管理
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # Brewfile に無いものを削除
    };

    # macOS GUI アプリ
    casks = [
      "affinity-photo"
      "clipy"
      "discord"
      "docker-desktop"
      "ghostty"
      "obsidian"
      "raycast"
      "visual-studio-code"
      "wezterm"
      "wireshark"
    ];
  };
}
