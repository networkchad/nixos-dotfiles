{ pkgs, ... }:

{
  home.packages = [
    (pkgs.slstatus.overrideAttrs (oldAttrs: {
      src = ../../src/slstatus;
    }))
  ];
}
