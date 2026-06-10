{ config, pkgs, ... }:

{
  services.xserver.windowManager.dwm = {
    enable = true;
    package = pkgs.dwm.overrideAttrs (oldAttrs: {
      src = ../../src/dwm;
    });
  };
}
