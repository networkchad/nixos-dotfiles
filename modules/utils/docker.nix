{ pkgs, ... }:

{
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true;

  environment.systemPackages = with pkgs; [ 
    docker-compose 
  ];
}
