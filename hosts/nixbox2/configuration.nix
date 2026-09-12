{ config, ... }:

# Host deltas only; everything shared lives in ../common.nix.
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/hardware/keyboard.nix
    ../../modules/nixos/hardware/nvidia.nix
  ];

  vars.keyboard = "us";

  vars.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
}
