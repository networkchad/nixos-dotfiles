{ config, ... }:

# Host deltas only; everything shared lives in ../common.nix.
{
  imports = [ ./hardware-configuration.nix ];

  services.xserver.xkb.layout = "us";

  # NVIDIA with PRIME offload, same shape as nixbox1; only the driver differs.
  # hardware.graphics is left alone: the X server already mkDefaults it.
  hardware.nvidia = {
    # The current release drops this GPU, so pin the last generation that
    # supports it -- and it is pre-Turing, so the open modules are not an option.
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Lets the containers docker starts (../common.nix) reach the GPU.
  hardware.nvidia-container-toolkit.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
}
