{ ... }:

{
  programs.ssh = {
    enable = true;
    includes = [ "config.local" ];

    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
      };

      # 内部ホスト (Host llm 等) は ~/.ssh/config.local に記述する

      "*" = {
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          AddKeysToAgent = "yes";
          IgnoreUnknown = "UseKeychain";
          UseKeychain = "yes";
          ControlMaster = "auto";
          ControlPath = "~/.ssh/sockets/%r@%h-%p";
          ControlPersist = "600";
        };
      };
    };
  };
}
