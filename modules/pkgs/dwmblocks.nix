{ config, pkgs, ... }:

{
  home.packages = [
    (pkgs.dwmblocks.overrideAttrs (oldAttrs: {
      src = ../../src/dwmblocks;
    }))
  ];
}
