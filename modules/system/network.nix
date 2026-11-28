{
  lib,
  users,
  ...
}:

# NetworkManager plus tailscaled. Tailnet membership is transport, not permission
# to reach every host listener; services must open their own ports.
{
  networking.networkmanager.enable = true;

  users.users = lib.genAttrs users (_: {
    extraGroups = [ "networkmanager" ];
  });

  services.tailscale = {
    enable = true;

    # Permit direct WireGuard connections on the physical NIC instead of DERP relays.
    openFirewall = true;
  };

}
