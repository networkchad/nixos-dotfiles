{
  description = "i use Nix btw";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  # The host table and the nixosSystem factory; no config here.
  outputs =
    { nixpkgs, home-manager, ... }:
    let
      inherit (nixpkgs) lib;

      # The host table: the only place a hostname, architecture or username
      # appears. Each entry needs ./hosts/<name>/{configuration,home,
      # hardware-configuration}.nix; a missing file or key fails evaluation
      # rather than importing nothing.
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

      # One host table entry -> one nixosSystem. Identity is passed to every
      # module as specialArgs; the three files under ./hosts/<name> are the
      # whole configuration.
      mkSystem =
        hostName:
        { system, users }:
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit hostName users; };

          modules = [
            ./hosts/common-configuration.nix
            ./hosts/${hostName}/hardware-configuration.nix
            ./hosts/${hostName}/configuration.nix

            home-manager.nixosModules.home-manager
            {
              # Both halves of the profile are assembled here, so no module names
              # a user or a machine.
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                users = lib.genAttrs users (username: {
                  home.username = username;
                  home.homeDirectory = "/home/${username}";
                  imports = [
                    ./hosts/common-home.nix
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
