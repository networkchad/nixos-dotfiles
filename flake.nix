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

      # A "session" bundles the system and home modules a WM stack needs.
      # Selecting a session below is path interpolation: an unknown value
      # fails evaluation instead of silently importing nothing.
      sessions = {
        dwm = {
          system = ./modules/nixos/sessions/dwm.nix;
          home   = ./modules/home/sessions/dwm.nix;
        };
        dwl = {
          system = ./modules/nixos/sessions/dwl.nix;
          home   = ./modules/home/sessions/dwl.nix;
        };
      };

      hosts = {
        nixbox1 = {
          system = "x86_64-linux";
          users = [ "anon" ];
          session = "dwm";
        };
        nixbox2 = {
          system = "x86_64-linux";
          users = [ "anon" ];
          session = "dwl";
        };
      };

      mkSystem = hostName: { system ? "x86_64-linux", users, session }:
        let
          sess = if lib.hasAttr session sessions
            then sessions.${session}
            else throw "unknown session '${session}' for host '${hostName}' (available: ${lib.concatStringsSep ", " (lib.attrNames sessions)})";
        in
        lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit hostName;
          };

          modules = [
            ./hosts/common.nix
            sess.system
            ./hosts/${hostName}/configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              home-manager.users = lib.genAttrs users (_: {
                imports = [
                  ./modules/home/common.nix
                  sess.home
                  ./hosts/${hostName}/home/anon.nix
                ];
              });
            }
          ];
        };
    in {
      nixosConfigurations = lib.mapAttrs mkSystem hosts;
    };
}
