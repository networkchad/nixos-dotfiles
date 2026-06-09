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
      
      sharedHomeManager = [
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.anon = import ./hosts/home.nix;
          home-manager.backupFileExtension = "backup";
        }
      ];
    in {
      nixosConfigurations = {
        
        base = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./modules/core/base.nix
          ] ++ sharedHomeManager;
        };

        nixbox1 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/nixbox1/configuration.nix
          ] ++ sharedHomeManager;
        };

      };
    };
}
