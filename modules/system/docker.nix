{
  pkgs,
  lib,
  users,
  ...
}:

# Docker, Compose, and daemon access. GPU access comes from ./nvidia.nix.
# Docker's NAT rules bypass normal input-filter assumptions: bind development-only
# published ports to 127.0.0.1 or a specific Tailscale address.
{
  virtualisation.docker.enable = true;

  users.users = lib.genAttrs users (_: {
    extraGroups = [ "docker" ];
  });

  environment.systemPackages = [ pkgs.docker-compose ];
}
