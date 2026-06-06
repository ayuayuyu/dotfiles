{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "config.local" ];

    settings = {
      "github.com" = {
        HostName = "github.com";
        User = "git";
      };

      # 内部ホスト (Host llm 等) は ~/.ssh/config.local に記述する

      "*" = {
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
        IdentityFile = "~/.ssh/id_ed25519";
        ForwardAgent = false;
        AddKeysToAgent = "yes";
        Compression = false;
        ControlMaster = "auto";
        ControlPath = "~/.ssh/sockets/%r@%h-%p";
        ControlPersist = "600";
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        IgnoreUnknown = "UseKeychain";
        UseKeychain = "yes";
      };
    };
  };
}
