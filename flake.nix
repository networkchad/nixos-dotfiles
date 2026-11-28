{
  description = "i use Nix btw";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Independent of stable nixpkgs; used only for opencode.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  # Host and profile assembly only; service configuration lives in modules/hosts.
  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      # Each entry requires hosts/<name>/{configuration,home,hardware-configuration}.nix.
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
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                # System specialArgs do not cross into Home Manager.
                extraSpecialArgs = {
                  inherit hostName;
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

      nixosConfigurations = lib.mapAttrs mkSystem hosts;
    in
    {
      inherit nixosConfigurations;

      # nixfmt-tree accepts the directory passed by `nix fmt`.
      formatter = lib.genAttrs (lib.unique (lib.mapAttrsToList (_: h: h.system) hosts)) (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );

      # Reuse the host overlay; flake check also evaluates every host.
      checks.x86_64-linux =
        let
          pkgs = nixosConfigurations.nixbox1.pkgs;
        in
        {
          inherit (pkgs)
            dwm
            st
            slock
            slstatus
            ;

          slstatus-status-shellcheck =
            pkgs.runCommand "slstatus-status-shellcheck"
              {
                nativeBuildInputs = [ pkgs.shellcheck ];
              }
              ''
                shellcheck ${./src/slstatus/scripts/status.sh}
                touch $out
              '';

          workflow-actionlint =
            pkgs.runCommand "workflow-actionlint"
              {
                nativeBuildInputs = [ pkgs.actionlint ];
              }
              ''
                actionlint ${./.github/workflows/check.yml}
                touch $out
              '';
        };
    };
}
