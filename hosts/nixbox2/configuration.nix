{ config, ... }:

# Host deltas only; ../common-configuration.nix and ../nvidia.nix hold the rest.
{
  imports = [ ../nvidia.nix ];

  services.xserver.xkb.layout = "us";

  # The current release drops this GPU, so pin the last generation that supports
  # it; it is pre-Turing, so the open modules are not an option either.
  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };
}
