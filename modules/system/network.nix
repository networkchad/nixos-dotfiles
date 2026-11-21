{
  lib,
  users,
  config,
  ...
}:

# NetworkManager, with the group its users join declared next to the module that
# creates it, plus a tailscale interface that is always up.
{
  networking.networkmanager.enable = true;

  users.users = lib.genAttrs users (_: {
    extraGroups = [ "networkmanager" ];
  });

  services.tailscale = {
    enable = true;

    # The underlay direction: 41641 is the wireguard port a peer hole-punches
    # toward, and those packets arrive on the physical NIC, never on tailscale0.
    # Blocked, a connection still comes up -- through a DERP relay, not directly.
    openFirewall = true;
  };

  # The overlay direction: inbound on tailscale0, so a peer reaching a service here
  # is never matched against the per-port list. Drop this and ssh-over-tailscale
  # stops working.
  networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
}
