{
  description = "i use Nix btw";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      hosts = {
        nixbox1 = { 
          users = [ "anon" ]; 
          sessionType = "x";
        }; 
        nixbox2 = { 
          users = [ "anon" ]; 
          sessionType = "wayland";
        };
      };

      mkSystem = hostName: { users, sessionType }: lib.nixosSystem {
        inherit system;
        
        specialArgs = { inherit sessionType; }; 

        modules = [
          ./hosts/${hostName}/configuration.nix
          
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            
            home-manager.users = lib.genAttrs users (user: 
              import ./hosts/${hostName}/home/${user}-${sessionType}.nix
            );
          }
        ];
      };

    in {
      nixosConfigurations = builtins.mapAttrs mkSystem hosts;
    };
}
