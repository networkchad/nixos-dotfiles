{ config, lib, ... }:

let
  cfg = config.video.prime;
in
# PRIME offload, shared by every NVIDIA host. Two things stay per-host: which
# driver generation to use (`open = true` for Turing and newer, otherwise a
# pinned `package`, since the open modules do not support pre-Turing GPUs) and
# the two PCI bus ids below -- those are facts about the board, and sharing them
# here because both current machines happen to agree would leave a third one
# with a black screen at boot.
{
  options.video.prime = {
    intelBusId = lib.mkOption {
      type = lib.types.str;
      example = "PCI:0:2:0";
      description = "PCI bus id of the iGPU that drives the session.";
    };

    nvidiaBusId = lib.mkOption {
      type = lib.types.str;
      example = "PCI:1:0:0";
      description = "PCI bus id of the NVIDIA GPU; `lspci -t` or `lspci -nn`.";
    };
  };

  config = {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      prime = {
        # The iGPU drives the session; `nvidia-offload <cmd>` puts one program on
        # the dGPU.
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        inherit (cfg) intelBusId nvidiaBusId;
      };
    };

    # Lets the containers docker starts reach the GPU.
    hardware.nvidia-container-toolkit.enable = true;
  };
}
