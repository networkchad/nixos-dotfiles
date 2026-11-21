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
    ../../modules/system/k8s.nix
    ../../modules/system/libvirtd.nix
    ../../modules/system/nvidia.nix
  ];

  # The keymap the desktop module's X server uses.
  services.xserver.xkb.layout = "jp";

  # The console gets X's layout too: the LUKS and login prompts, and every
  # Ctrl+Alt+F2 rescue, are otherwise US while the session is JP.
  console.useXkbConfig = true;

  # lspci on this board: iGPU on bus 0, dGPU on bus 1.
  video.prime = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # Turing and newer, so the open modules at the kernel's default generation.
  hardware.nvidia.open = true;

  # The cluster's front door: every route behind the Gateway shares MetalLB's
  # first address on the kind bridge. Confirm it after a fresh cluster with
  # `kubectl -n web get gateway web` -- the pool is .240-.250.
  networking.hosts."172.18.0.240" = [
    "homelab.internal"
    "auth.homelab.internal"
    "headlamp.homelab.internal"
    "grafana.homelab.internal"
  ];
}
