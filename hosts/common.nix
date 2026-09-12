{ pkgs, hostName, ... }:

# System config shared by every host; per-host deltas live in ./<name>/.
{
  imports = [
    ../modules/nixos/base/boot.nix
    ../modules/nixos/base/nix.nix
    ../modules/nixos/base/users.nix
    ../modules/nixos/base/i18n.nix
    ../modules/nixos/base/network.nix
    ../modules/nixos/base/sound.nix
    ../modules/nixos/desktop.nix
    ../modules/nixos/services/docker.nix
    ../modules/nixos/services/tailscale.nix
  ];

  networking.hostName = hostName;

  environment.systemPackages = with pkgs; [
    wget
    git
  ];

  # Lets binaries installed outside Nix find their libraries.
  programs.nix-ld.enable = true;

  system.stateVersion = "26.05";
}
