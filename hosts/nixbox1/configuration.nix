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

  # The console gets the same layout as X. This machine is used on the tty
  # before startx -- the LUKS prompt and the login prompt are otherwise US while
  # the session is JP -- and so is every Ctrl+Alt+F2 rescue.
  console.useXkbConfig = true;

  # lspci on this board: iGPU on bus 0, dGPU on bus 1.
  video.prime = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

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
