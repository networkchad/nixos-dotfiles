{
  description = "i use Nix btw";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  # The host table: the only place a hostname, architecture or username appears.
  # Each entry needs ./hosts/<name>/{configuration,home,hardware-configuration}.nix;
  # a missing file or key fails evaluation rather than importing nothing.
  outputs =
    { nixpkgs, home-manager, ... }:
    let
      inherit (nixpkgs) lib;

      hosts = {
        nixbox1 = {
          system = "x86_64-linux";
          users = [ "anon" ];
        };

        nixbox2 = {
          system = "x86_64-linux";
          users = [ "anon" ];
        };
      };

      # One host table entry -> one nixosSystem.
      mkSystem =
        hostName: { system, users }:
        lib.nixosSystem {
          inherit system;

          # Visible to every module; `users` is what creates the accounts.
          specialArgs = { inherit hostName users; };

          modules = [
            # Must come before any module that mentions pkgs.dwm & friends.
            { nixpkgs.overlays = [ (import ./overlays/vendored.nix) ]; }

            ./hosts/common.nix
            ./hosts/${hostName}/configuration.nix

            home-manager.nixosModules.home-manager
            {
              # Identity comes from the host table, so no home module names a user.
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                users = lib.genAttrs users (username: {
                  home.username = username;
                  home.homeDirectory = "/home/${username}";
                  imports = [
                    ./modules/home.nix
                    ./hosts/${hostName}/home.nix
                  ];
                });
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = lib.mapAttrs mkSystem hosts;
    };
}
