{ config, ... }:

# One line per service this machine runs; the shared core is imported by the
# flake (../../modules/system/base.nix) and the board facts live in
# ./hardware-configuration.nix.
{
  imports = [
    ../../modules/system/desktop.nix
    ../../modules/system/network.nix
    ../../modules/system/docker.nix
    ../../modules/system/libvirtd.nix
    ../../modules/system/nvidia.nix
  ];

  # The keymap the desktop module's X server uses.
  services.xserver.xkb.layout = "jp";

  # The console gets the same layout as X. This machine is used on the tty
  # before startx -- the LUKS prompt and the login prompt are otherwise US while
  # the session is JP -- and so is every Ctrl+Alt+F2 rescue.
  console.useXkbConfig = true;

  # lspci on this board: iGPU on bus 0, dGPU on bus 1.
  video.prime = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # Open modules: right for this GPU (Turing and newer), at the kernel's default
  # driver generation.
  hardware.nvidia.open = true;
}
