{ pkgs, ... }:

{
  home.packages = [
    (pkgs.dwl.overrideAttrs (oldAttrs: {
      src = ../../src/dwl; 
      
      buildInputs = (oldAttrs.buildInputs or []) ++ [
        pkgs.fcft
        pkgs.libdrm
      ];
    }))
  ];
}
