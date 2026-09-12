{
  description = "i use Nix btw";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Everything is driven by the host table; lib/make-system.nix turns one of
  # its entries into a system. Nothing else is exported on purpose.
  outputs =
    { nixpkgs, home-manager, ... }:
    let
      mkSystem = import ./lib/make-system.nix { inherit nixpkgs home-manager; };
      hosts = import ./hosts/default.nix;
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs mkSystem hosts;
    };
}
