{ config, pkgs, ... }:

{
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  console.useXkbConfig = true;
}
