{ config, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  
  environment.systemPackages = with pkgs; [
    qemu
    dnsmasq
  ];

  users.users.anon.extraGroups = [ "libvirtd" ];

  systemd.tmpfiles.rules = [
    "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware"
  ];
}
