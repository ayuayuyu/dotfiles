{ config, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # 既存の starship.toml をそのまま配置
  xdg.configFile."starship.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/config/starship.toml";
}
