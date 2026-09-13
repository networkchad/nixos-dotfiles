{
  lib,
  pkgs,
  users,
  ...
}:

# Host deltas only; everything shared lives in ../common-configuration.nix.
{
  imports = [ ./hardware-configuration.nix ];

  services.xserver.xkb.layout = "jp";

  # NVIDIA with PRIME offload: the iGPU drives the session and
  # `nvidia-offload <cmd>` puts one program on the dGPU. Both bus ids are this
  # machine's PCI addresses (`xrandr --listproviders`, or lspci).
  # hardware.graphics is left alone: the X server already mkDefaults it.
  hardware.nvidia = {
    # Open kernel modules: right for this GPU (Turing and newer). The driver
    # generation is the kernel package's default, nvidiaPackages.stable.
    open = true;
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

  # Lets the containers docker starts (../common-configuration.nix) reach the GPU.
  hardware.nvidia-container-toolkit.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  # VM stack, this machine only.
  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu_kvm;
  };

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [ dnsmasq ];

  users.users = lib.genAttrs users (_: {
    extraGroups = [ "libvirtd" ];
  });

  # The firewall makes room for libvirt's own bridge.
  networking.firewall.trustedInterfaces = [ "virbr0" ];
}
