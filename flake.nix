{
  description = "i use Nix btw";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Not `follows = nixpkgs`: the one set that has to float, for `opencode` alone.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  # The host table and the nixosSystem factory; no config here.
  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      # The only place a hostname or a username appears. Each entry needs
      # ./hosts/<name>/{configuration,home,hardware-configuration}.nix, and a missing
      # file or key fails evaluation rather than importing nothing.
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

      # One host table entry -> one nixosSystem. Identity reaches every module as
      # specialArgs; everything a host runs it imports by name itself.
      mkSystem =
        hostName:
        { system, users }:
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit hostName users; };

          modules = [
            ./modules/system/base.nix
            ./hosts/${hostName}/hardware-configuration.nix
            ./hosts/${hostName}/configuration.nix

            home-manager.nixosModules.home-manager
            {
              # Both halves of the profile are assembled here, so no module names a
              # user or a machine.
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                # The specialArgs above stop at the system layer.
                extraSpecialArgs = {
                  inherit hostName;
                  # For the user half only -- ./modules/home/base.nix says what uses it.
                  pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
                };
                users = lib.genAttrs users (username: {
                  home.username = username;
                  home.homeDirectory = "/home/${username}";
                  imports = [
                    ./modules/home/base.nix
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

      # `nix fmt` on the nixpkgs this lock pins, in the style the tree is written in.
      # `nixfmt-tree`, not bare `nixfmt`: `nix fmt` hands the formatter the flake
      # directory and nixfmt 1.5 no longer takes one. `nix fmt -- --fail-on-change`
      # is the gate CI uses.
      formatter = lib.genAttrs (lib.unique (lib.mapAttrsToList (_: h: h.system) hosts)) (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );
    };
}
