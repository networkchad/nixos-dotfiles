{
  lib,
  pkgs,
  users,
  ...
}:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu_kvm;
  };

  programs.virt-manager.enable = true;

  users.users = lib.genAttrs users (_: {
    extraGroups = [ "libvirtd" ];
  });

  environment.systemPackages = with pkgs; [
    dnsmasq
  ];
}
