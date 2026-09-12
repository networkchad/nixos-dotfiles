{ config, lib, ... }:

# NVIDIA with PRIME offload, imported by hosts/common.nix. What differs per
# machine -- driver flavour and the two PCI bus ids -- comes from vars.nvidia.
let
  cfg = config.vars.nvidia;
in
{
  options.vars.nvidia = {
    open = lib.mkEnableOption "the open NVIDIA kernel modules (Turing and newer)";

    package = lib.mkOption {
      type = lib.types.package;
      default = config.boot.kernelPackages.nvidiaPackages.stable;
      description = "Driver generation; dropped GPUs need nvidiaPackages.legacy_<series>.";
    };

    intelBusId = lib.mkOption {
      type = lib.types.str;
      description = "PCI bus id of the iGPU.";
    };

    nvidiaBusId = lib.mkOption {
      type = lib.types.str;
      description = "PCI bus id of the dGPU.";
    };
  };

  config = {
    # hardware.graphics is mkDefault'd by the X server, so it is not set here.
    hardware.nvidia = {
      inherit (cfg) open package;
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
        inherit (cfg) intelBusId nvidiaBusId;
      };
    };

    # Here rather than with docker, so the docker config works on a GPU-less host.
    hardware.nvidia-container-toolkit.enable = true;

    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
