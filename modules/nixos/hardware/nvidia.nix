{ config, lib, ... }:

# NVIDIA with PRIME offload. The three facts that differ per machine (driver
# flavour and the two PCI bus ids) are declared by hosts/<name>/configuration.nix.
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
    hardware = {
      graphics.enable = true;

      nvidia = {
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
    };

    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
