{
  description = "ayuayuyu's dotfiles - nix-darwin + home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      username = "ayuayuyu";
    in
    {
      # macOS: nix-darwin + home-manager
      darwinConfigurations."ayuayuyu-mac" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/darwin
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.users.${username} = import ./home;
            home-manager.extraSpecialArgs = {
              inherit username;
              homeDirectory = "/Users/${username}";
              isLinux = false;
            };
          }
        ];
      };

      # Linux: home-manager standalone
      homeConfigurations."ayuayuyu-linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit username;
          homeDirectory = "/home/${username}";
          isLinux = true;
        };
        modules = [
          ./home
          ./hosts/linux
        ];
      };
    };
}
