{
  pkgs,
  lib,
  users,
  ...
}:

# The daemon, the group that may talk to it, and the compose CLI. On GPU hosts
# ./nvidia.nix additionally lets containers reach the GPU.
{
  virtualisation.docker.enable = true;

  users.users = lib.genAttrs users (_: {
    extraGroups = [ "docker" ];
  });

  environment.systemPackages = [ pkgs.docker-compose ];
}
