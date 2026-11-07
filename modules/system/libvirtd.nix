{
  pkgs,
  lib,
  users,
  ...
}:

# The VM stack, for the hosts that run VMs: libvirt + qemu, the manager GUI, the
# group that may drive the daemon, dnsmasq for the NAT network, and trust for the
# bridge libvirt defines. A host that imports nothing here has no `libvirtd`
# group at all.
{
  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu_kvm; # host-passthrough CPU, no emulation targets
  };

  programs.virt-manager.enable = true;

  environment.systemPackages = [ pkgs.dnsmasq ];

  users.users = lib.genAttrs users (_: {
    extraGroups = [ "libvirtd" ];
  });

  networking.firewall.trustedInterfaces = [ "virbr0" ]; # libvirt's bridge
}
