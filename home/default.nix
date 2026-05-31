{ pkgs, config, username, homeDirectory, isLinux, ... }:

{
  imports = [
    ./packages.nix
    ./shell/zsh.nix
    ./shell/starship.nix
    ./git.nix
    ./tmux.nix
    ./ssh.nix
  ];

  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "24.11";

  # --- raw 設定ファイルの配置 ---
  xdg.configFile = {
    # Neovim (書き込み必要: lazy-lock.json)
    "nvim".source =
      config.lib.file.mkOutOfStoreSymlink
        "${homeDirectory}/dotfiles/config/nvim";

    # Ghostty
    "ghostty/config".source =
      config.lib.file.mkOutOfStoreSymlink
        "${homeDirectory}/dotfiles/config/ghostty/config";

    # WezTerm (Lua 設定が複雑なため raw 配置)
    "wezterm".source =
      config.lib.file.mkOutOfStoreSymlink
        "${homeDirectory}/dotfiles/config/wezterm";

    # mise
    "mise/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink
        "${homeDirectory}/dotfiles/config/mise/config.toml";

    # Wireshark (書き込み必要: recent ファイル)
    "wireshark".source =
      config.lib.file.mkOutOfStoreSymlink
        "${homeDirectory}/dotfiles/config/wireshark";

    # Git config (programs.git で管理するが、既存の excludesFile パスとの互換性のため)
    # → programs.git が ~/.config/git/ignore を自動生成
  };

  # home-manager 自身の管理を有効化
  programs.home-manager.enable = true;
}
