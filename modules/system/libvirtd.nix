{
  pkgs,
  lib,
  users,
  ...
}:

# libvirt + qemu, the manager GUI, the group that may drive the daemon, and trust
# for the bridge libvirt defines. A host importing nothing here has no `libvirtd`
# group at all.
#
# The default NAT network does need a dnsmasq and this file declares none: the
# libvirt derivation puts one on the daemon's own PATH (`binPath`, baked into the
# libvirtd wrapper), so a system-wide copy would be a second one nothing asked for.
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
