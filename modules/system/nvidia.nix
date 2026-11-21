{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.video.prime;
in
# PRIME offload, shared by every NVIDIA host. Two things stay per-host: the driver
# generation (`open = true` for Turing and newer, otherwise a pinned `package`,
# since the open modules do not support pre-Turing) and the two PCI bus ids -- facts
# about the board that would leave a third machine black-screened if they were
# shared just because the current two agree.
#
# This is also the only module that needs an unfree grant, so the grant lives here.
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
    # arrives under several names (nvidia-x11, nvidia-open, nvidia-settings,
    # nvidia-container-toolkit, ...) and which exist changes between releases.
    # Nothing else needs the grant; brave is MPL-2.0. `useGlobalPkgs` shares this
    # config with home-manager.
    nixpkgs.config.allowUnfreePredicate = pkg: lib.hasPrefix "nvidia" (lib.getName pkg);

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        # Runtime D3 driven by the driver is a feature of the *open* modules; on the
        # proprietary blob the parameter is accepted and ignored. So this line of the
        # PRIME shape does not travel either, and reads the host's own `open`.
        finegrained = config.hardware.nvidia.open;
      };
      # Buys NVreg_PreserveVideoMemoryAllocations=1, plus one of two ways of being
      # told the suspend is coming. Which one is `kernelSuspendNotifier`, and 26.05
      # defaults it to `open && package.version >= 595`: on the open modules the
      # driver takes the event from a kernel notifier and nixpkgs installs no sleep
      # units at all, on the blob it falls back to
      # nvidia-suspend/resume/hibernate.service. Left at the default so it follows
      # whichever driver the host chose; pin it only if a bump ever switches a host
      # over mid-deployment.
      #
      # The same on both paths: the preservation needs the persistence daemon, which
      # is a separate switch and off by default.
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

    # Hardware decode for the GPU that actually drives the session. Offload puts the
    # desktop on the iGPU, but only the NVIDIA side of VA-API arrives by itself, so
    # with nothing for Intel the browsers decode in software on the panel's own GPU.
    # Keyed off the host's `open` the way `finegrained` is -- which is also where the
    # call gets made that nixbox2 (legacy blob) goes without. `vainfo` lists what a
    # browser needs.
    hardware.graphics.extraPackages = lib.optionals config.hardware.nvidia.open (
      with pkgs;
      [
        intel-media-driver # the VA-API driver, Gen8 and newer
        libva-utils # vainfo
      ]
    );

    # Lets the containers docker starts reach the GPU.
    hardware.nvidia-container-toolkit.enable = true;
  };
}
