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

      # The host table: the only place a hostname or a username appears. The
      # architecture is repeated inside each generated
      # ./hosts/<name>/hardware-configuration.nix (`nixpkgs.hostPlatform`), which
      # nixos-generate-config owns and nobody hand-edits. Each entry needs
      # ./hosts/<name>/{configuration,home,hardware-configuration}.nix; a missing
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

      # One host table entry -> one nixosSystem. Identity is passed to every
      # module as specialArgs. Each host gets the two `base` modules and its own
      # two files; everything else it runs is imported by name in
      # ./hosts/<name>/configuration.nix from ./modules/{system,home}/.
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

      # `nix fmt` using the nixpkgs this lock pins: nixfmt, the style the tree is
      # already written in.
      formatter = lib.genAttrs (lib.unique (lib.mapAttrsToList (_: h: h.system) hosts)) (
        system: nixpkgs.legacyPackages.${system}.nixfmt
      );
    };
}
