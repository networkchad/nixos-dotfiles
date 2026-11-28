{
  pkgs,
  lib,
  users,
  ...
}:

# libvirt, unprivileged QEMU, and virt-manager. The libvirt wrapper already carries
# dnsmasq for its default NAT network; no system-wide copy is needed.
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm; # host-architecture QEMU targets only
      # A guest escape reaches qemu-libvirtd rather than a root QEMU process.
      runAsRoot = false;
    };
  };

  programs.virt-manager.enable = true;

  users.users = lib.genAttrs users (_: {
    extraGroups = [ "libvirtd" ];
  });

  # Permit only host-side DHCP/DNS; libvirt owns its NAT and forwarding rules.
  networking.firewall.interfaces.virbr0 = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [
      53
      67
    ];
  };
}
