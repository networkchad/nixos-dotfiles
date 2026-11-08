{ config, ... }:

# One line per service this machine runs; the shared core is imported by the
# flake (../../modules/system/base.nix) and the board facts live in
# ./hardware-configuration.nix.
{
  imports = [
    ../../modules/system/desktop.nix
    ../../modules/system/network.nix
    ../../modules/system/power.nix
    ../../modules/system/docker.nix
    ../../modules/system/nvidia.nix
  ];

  # The keymap the desktop module's X server uses; US is also the console
  # default, so no console.useXkbConfig here.
  services.xserver.xkb.layout = "us";

  # lspci on this board: same topology as nixbox1, stated here because it is a
  # fact about this machine, not about the shared module.
  video.prime = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # The current release drops this GPU, so pin the last generation that supports
  # it; it is pre-Turing, so the open modules are not an option either.
  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };
}
