{ ... }:

{
  # macOS システム設定 (defaults write の宣言的管理)
  system.defaults = {
    # スクロール方向: ナチュラル
    NSGlobalDomain."com.apple.swipescrolldirection" = true;

    # Dock
    dock = {
      autohide = false;
      show-recents = false;
    };

    # Finder
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
    };
  };
}
