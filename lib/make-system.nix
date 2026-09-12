# One host table entry -> one nixosSystem.
{ nixpkgs, home-manager }:
let
  inherit (nixpkgs) lib;
  sessions = import ../modules/sessions.nix;
in
hostName: host:
let
  # A typo in the host table should fail loudly, not import nothing.
  session =
    if lib.hasAttr host.session sessions then
      sessions.${host.session}
    else
      throw "host '${hostName}': unknown session '${host.session}' (available: ${lib.concatStringsSep ", " (lib.attrNames sessions)})";

  inherit (host) users;
in
lib.nixosSystem {
  inherit (host) system;

  # Visible to every system module (users.nix, network.nix, docker.nix, qemu.nix).
  specialArgs = { inherit hostName users; };

  modules = [
    # Must come before any module that mentions pkgs.dwl & friends.
    { nixpkgs.overlays = [ (import ../overlays/vendored.nix) ]; }

    ../hosts/common.nix
    session.system
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
            session.home
            ../hosts/${hostName}/home.nix
          ];
        });
      };
    }
  ];
}
