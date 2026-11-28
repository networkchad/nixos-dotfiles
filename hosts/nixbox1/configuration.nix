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
    ../../modules/system/k8s.nix
    ../../modules/system/libvirtd.nix
    ../../modules/system/nvidia.nix
  ];

  # Install-time compatibility baseline, not the current flake release.
  system.stateVersion = "26.05";

  services.xserver.xkb.layout = "jp";

  # Use JP for LUKS/login prompts and rescue ttys too.
  console.useXkbConfig = true;

  hardware.nvidia = {
    # Turing or newer; current open modules support this GPU.
    open = true;

    # lspci: iGPU on bus 0, dGPU on bus 1.
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
