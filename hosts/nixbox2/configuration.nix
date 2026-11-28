{ ... }:

# Host service selection and hardware/session deltas.
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

  # Install-time compatibility baseline, not the current flake release.
  system.stateVersion = "26.05";

  # Pre-Turing GPU: open modules are unsupported; legacy 580 is the last usable branch.
  hardware.nvidia = {
    open = false;
    branch = "legacy_580";

    # Same topology as nixbox1, but retained as a board-specific fact.
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
