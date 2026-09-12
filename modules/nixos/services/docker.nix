{
  lib,
  pkgs,
  users,
  ...
}:

{
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true;

  users.users = lib.genAttrs users (_: {
    extraGroups = [ "docker" ];
  });

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
