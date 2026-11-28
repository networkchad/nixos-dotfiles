{
  config,
  lib,
  pkgs,
  ...
}:

# Shared PRIME offload. Each host selects its driver generation and native PCI bus-ID
# options; never copy board-specific IDs between machines.
{
  # Keep the unfree grant scoped to NVIDIA package-name prefixes.
  nixpkgs.config.allowUnfreePredicate = pkg: lib.hasPrefix "nvidia" (lib.getName pkg);

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      # Enable fine-grained power management on the newer open-driver host only.
      finegrained = config.hardware.nvidia.open;
    };
    # Preserve video memory without nvidiaPersistenced's always-running daemon.
    prime = {
      # The iGPU drives the session; nvidia-offload selects the dGPU per process.
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };

  # Intel drives the session, so browsers need Intel VA-API for hardware decoding.
  # On these hosts `open` also selects the machine using this driver. vainfo diagnoses it.
  hardware.graphics.extraPackages = lib.optionals config.hardware.nvidia.open (
    with pkgs;
    [
      intel-media-driver
      libva-utils
    ]
  );

  # GPU access for Docker containers.
  hardware.nvidia-container-toolkit.enable = true;
}
