{
  pkgs,
  lib,
  users,
  ...
}:

# The VM stack, for the hosts that run VMs: libvirt + qemu, the manager GUI, the
# group that may drive the daemon, and trust for the bridge libvirt defines. A
# host that imports nothing here has no `libvirtd` group at all.
#
# The default NAT network does need a dnsmasq and this file declares none: the
# libvirt derivation puts it on the daemon's own PATH (`binPath` in
# pkgs/by-name/li/libvirt/package.nix, baked into the sbin/libvirtd wrapper), so a
# copy on the system PATH would be a second one that nothing asked for. Checked on
# the running host: the dnsmasq serving `default` runs from the store path baked
# into that wrapper, not from /run/current-system/sw/bin.
{
  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu_kvm; # host-passthrough CPU, no emulation targets
  };

  programs.virt-manager.enable = true;

  users.users = lib.genAttrs users (_: {
    extraGroups = [ "libvirtd" ];
  });

  networking.firewall.trustedInterfaces = [ "virbr0" ]; # libvirt's bridge
}
