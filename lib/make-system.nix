# One host table entry -> one nixosSystem.
{ nixpkgs, home-manager }:
hostName: { system, users }:
let
  inherit (nixpkgs) lib;
in
lib.nixosSystem {
  inherit system;

  # Visible to every system module (users.nix, network.nix, docker.nix, qemu.nix).
  specialArgs = { inherit hostName users; };

  modules = [
    # Must come before any module that mentions pkgs.dwm & friends.
    { nixpkgs.overlays = [ (import ../overlays/vendored.nix) ]; }

    ../hosts/common.nix
    ../hosts/${hostName}/configuration.nix

    home-manager.nixosModules.home-manager
    {
      # Identity comes from the host table, so no home module hardcodes a username.
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users = lib.genAttrs users (username: {
          home.username = username;
          home.homeDirectory = "/home/${username}";
          imports = [
            ../modules/home/common.nix
            ../modules/home/desktop.nix
            ../hosts/${hostName}/home.nix
          ];
        });
      };
    }
  ];
}
