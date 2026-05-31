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

      "llm" = {
        hostname = "REDACTED_HOST";
        user = "REDACTED_USER";
        localForwards = [
          { bind.port = 8080; host.address = "127.0.0.1"; host.port = 8080; }
          { bind.port = 11434; host.address = "127.0.0.1"; host.port = 11434; }
        ];
      };

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
