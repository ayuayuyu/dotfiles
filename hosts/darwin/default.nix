{ pkgs, ... }:

{
  imports = [
    ./homebrew.nix
    ./system.nix
  ];

  # プライマリユーザー (nix-darwin + home-manager 連携で必須)
  users.users.ayuayuyu = {
    name = "ayuayuyu";
    home = "/Users/ayuayuyu";
  };
  system.primaryUser = "ayuayuyu";

  # Determinate Nix を使用しているため、nix-darwin の Nix 管理は無効化
  nix.enable = false;

  # システムレベルで zsh を有効化
  programs.zsh.enable = true;

  # Touch ID で sudo 認証
  security.pam.services.sudo_local.touchIdAuth = true;

  # プラットフォーム
  nixpkgs.hostPlatform = "aarch64-darwin";

  # nix-darwin のステートバージョン
  system.stateVersion = 5;
}
