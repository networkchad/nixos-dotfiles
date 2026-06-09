{
  description = "Modularized Multi-Profile NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        
        nixbox1 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/nixbox1/configuration.nix
            
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.anon = import ./hosts/nixbox1/home.nix;
            }
          ];
        };

        # Example of how you would add a second host with a completely different user profile later:
        # nixbox2 = nixpkgs.lib.nixosSystem {
        #   inherit system;
        #   modules = [
        #     ./hosts/nixbox2/configuration.nix
        #     home-manager.nixosModules.home-manager
        #     {
        #       home-manager.useGlobalPkgs = true;
        #       home-manager.useUserPackages = true;
        #       home-manager.backupFileExtension = "backup";
        #       home-manager.users.differentuser = import ./hosts/nixbox2/differentuser.nix;
        #     }
        #   ];
        # };

      };
    };
}
