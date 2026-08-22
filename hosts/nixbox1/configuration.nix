{ ... }:

# Host-specific deltas only; everything shared lives in ../common.nix.
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/nvidia-open.nix
    ../../modules/nixos/keyboard-jp.nix
    ../../modules/nixos/qemu.nix
  ];

  users.users.anon.extraGroups = [ "libvirtd" ];
}
