{ config, pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.dwl.overrideAttrs (oldAttrs: {
      src = ../../src/dwl; 
      
      buildInputs = (oldAttrs.buildInputs or []) ++ [
        pkgs.fcft
        pkgs.libdrm
      ];
    }))
  ];
}
