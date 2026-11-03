{ config, ... }:

# Host deltas only; ../common-configuration.nix and ../nvidia.nix hold the rest.
{
  imports = [ ../nvidia.nix ];

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
