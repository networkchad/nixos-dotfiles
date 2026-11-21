{ config, ... }:

# One line per service this machine runs; the shared core is imported by the flake
# and the board facts live in ./hardware-configuration.nix.
{
  imports = [
    ../../modules/system/btrfs.nix
    ../../modules/system/desktop.nix
    ../../modules/system/network.nix
    ../../modules/system/power.nix
    ../../modules/system/memory.nix
    ../../modules/system/docker.nix
    ../../modules/system/nvidia.nix
  ];

  # The keymap the desktop module's X server uses; US is also the console default, so
  # no console.useXkbConfig here.
  services.xserver.xkb.layout = "us";

  # Same topology as nixbox1, stated here because it is a fact about this board.
  video.prime = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # Pre-Turing, so the open modules are not an option, and the current release drops
  # this GPU -- hence the pinned last generation that supports it.
  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };
}
