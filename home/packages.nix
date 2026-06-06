{ pkgs, isLinux, ... }:

{
  home.packages = with pkgs; [
    # 必須ツール
    # git は programs.git.enable で home-manager が入れるため重複させない
    gh

    # 快適な CLI 体験
    # fzf, zoxide, mise, starship は programs.* で管理
    bat
    eza
    ripgrep
    fd
    lazygit

    # エディタ / ターミナル
    neovim
    tmux

    # フォント
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
  ] ++ pkgs.lib.optionals isLinux [
    # Linux 固有パッケージ
    wezterm
    wireshark
  ];
}
