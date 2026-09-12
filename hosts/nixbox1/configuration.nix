{
  lib,
  pkgs,
  users,
  ...
}:

# Host deltas only; everything shared lives in ../common.nix.
{
  imports = [ ./hardware-configuration.nix ];

  services.xserver.xkb.layout = "jp";

  vars.nvidia = {
    open = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

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
