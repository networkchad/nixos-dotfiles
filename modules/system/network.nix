{
  lib,
  users,
  config,
  ...
}:

# Connectivity both laptops use everywhere: NetworkManager, with the group its
# users join declared next to the module that creates it, and a tailscale
# interface that is always up.
{
  networking.networkmanager.enable = true;

  users.users = lib.genAttrs users (_: {
    extraGroups = [ "networkmanager" ];
  });

  services.tailscale = {
    enable = true;

    # openFirewall (off by default) opens tailscale's UDP port. Trusting the
    # interface instead of per-port rules lets peers reach services here.
    openFirewall = true;
  };
  networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
}
