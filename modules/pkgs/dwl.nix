{ config, pkgs, ... }:

{
  home.packages = [
    (pkgs.dwl.overrideAttrs (oldAttrs: {
      src = ../../src/dwl; 
    }))
  ];
}
