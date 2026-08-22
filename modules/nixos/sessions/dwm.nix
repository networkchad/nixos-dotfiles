{ pkgs, ... }:

# System side of the dwm (X11) session.
{
  imports = [
    ../x11.nix
    ../slock.nix
  ];

  services.xserver.windowManager.dwm = {
    enable = true;
    package = pkgs.dwm.overrideAttrs (oldAttrs: {
      src = ../../../src/dwm;
    });
  };

  services.picom.enable = true;
}
