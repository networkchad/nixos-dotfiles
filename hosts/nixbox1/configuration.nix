{ config, ... }:

# Host deltas only; everything shared lives in ../common.nix.
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/hardware/keyboard.nix
    ../../modules/nixos/hardware/nvidia.nix
    ../../modules/nixos/services/qemu.nix
  ];

  vars.keyboard = "jp";

  vars.nvidia = {
    open = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
}
