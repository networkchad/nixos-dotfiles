{ ... }:

# Host-specific deltas only; everything shared lives in ../common.nix.
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/nvidia-legacy.nix
    ../../modules/nixos/keyboard-us.nix
  ];
}
