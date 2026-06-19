{ config, pkgs, ... }:

{
  services.xserver.xkb = {
    layout = "jp";
    variant = "";
  };

  console.useXkbConfig = true;
}
