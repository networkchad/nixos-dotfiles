{
  description = "i use Nix btw";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;

      hosts = {
        nixbox1 = {
          system = "x86_64-linux";
          users = [ "anon" ];
          sessionType = "dwm";
        };

        nixbox2 = {
          system = "x86_64-linux";
          users = [ "anon" ];
          sessionType = "niri";
        };
        
      };

      mkSystem = hostName: { users, sessionType, system ? "x86_64-linux" }:
        lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit hostName sessionType;
          };

          modules = [
            ./hosts/${hostName}/configuration.nix

            home-manager.nixosModules.home-manager

            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              home-manager.extraSpecialArgs = {
                inherit hostName sessionType;
              };

              home-manager.users =
                lib.genAttrs users (user:
                  import ./hosts/${hostName}/home/${user}.nix
                );
            }
          ];
        };
    in {
      nixosConfigurations = builtins.mapAttrs mkSystem hosts;
    };
}
