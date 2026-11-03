{
  lib,
  pkgs,
  users,
  ...
}:

# Host deltas only; ../common-configuration.nix and ../nvidia.nix hold the rest.
{
  imports = [ ../nvidia.nix ];

  services.xserver.xkb.layout = "jp";

  # Open modules: right for this GPU (Turing and newer), at the kernel's default
  # driver generation.
  hardware.nvidia.open = true;

  # VM stack, this machine only.
  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu_kvm; # host-passthrough CPU, no emulation targets
  };
  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [ dnsmasq ];

  users.users = lib.genAttrs users (_: {
    extraGroups = [ "libvirtd" ];
  });

  networking.firewall.trustedInterfaces = [ "virbr0" ]; # libvirt's bridge
}
