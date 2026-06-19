{ config, pkgs, ... }:

{
  services.xserver.xkb = {
    layout = "jp";
    variant = "";
  };
}
