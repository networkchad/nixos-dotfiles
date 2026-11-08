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

    # These two firewall lines are two directions, not two ways of doing one
    # thing, which is why both are here. This one expands to
    # `networking.firewall.allowedUDPPorts = [ 41641 ]`
    # (services/networking/tailscale.nix) -- a rule on *every* interface, for the
    # underlay: 41641 is the wireguard port a peer hole-punches toward, and those
    # packets arrive on the physical NIC, never on tailscale0. With it blocked a
    # connection still comes up, just through a DERP relay instead of directly.
    openFirewall = true;
  };

  # The overlay direction: inbound on tailscale0, so a peer reaching a service
  # here is not matched against the per-port list at all. Drop this and
  # ssh-over-tailscale stops working; drop `openFirewall` and what you lose is a
  # direct connection, not the tunnel.
  networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
}
