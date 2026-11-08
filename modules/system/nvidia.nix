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
#
# This module is also the only thing in the tree that needs an unfree grant, so
# the grant lives here: a host that does not import it asks for none.
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
    # The unfree set is exactly the NVIDIA stack -- a prefix, because the driver
    # arrives under several names (nixbox1's closure alone carries nvidia-x11,
    # nvidia-open, nvidia-settings, nvidia-x11-bin, nvidia-container-toolkit,
    # nvidia-vaapi-driver) and which of them exist changes between nixpkgs
    # releases. Checked both ways: comment this line out and evaluating nixbox1
    # dies on "Refusing to evaluate package 'nvidia-x11-…' because it has an
    # unfree license"; with only this prefix, both systems evaluate, which also
    # proves nothing else needs the grant. brave is not in it -- MPL-2.0,
    # `meta.unfree = false` -- despite what this line used to comment.
    # `useGlobalPkgs` shares the config with home-manager.
    nixpkgs.config.allowUnfreePredicate = pkg: lib.hasPrefix "nvidia" (lib.getName pkg);

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        # Runtime D3 driven by the driver itself is a feature of the *open*
        # modules; on a pre-Turing board pinned to the proprietary blob the
        # `NVreg_DynamicPowerManagement=0x02` module parameter is accepted and
        # ignored. So this one line of the PRIME shape does not travel, and it
        # reads the host's own `hardware.nvidia.open` instead of being stated
        # here for the same reason the two bus ids are not.
        finegrained = config.hardware.nvidia.open;
      };
      # powerManagement.enable buys two things nixpkgs wires up: the
      # nvidia-suspend/resume/hibernate system units, and
      # NVreg_PreserveVideoMemoryAllocations=1 (hardware/video/nvidia.nix) so the
      # driver can drop its allocations across S3. That preservation depends on
      # the persistence daemon, which is a separate switch and off by default --
      # without it the first resume from a lid close is the interesting one.
      nvidiaPersistenced = true;
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
