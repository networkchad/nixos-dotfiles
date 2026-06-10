{ config, pkgs, ... }:

{
  home.packages = [
    (pkgs.st.overrideAttrs (oldAttrs: {
      src = ../../src/st;
    }))
  ];
}
