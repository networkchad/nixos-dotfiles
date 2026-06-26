{ pkgs, ... }:

{
  programs.slock = {
    enable = true;
    package = pkgs.slock.overrideAttrs (oldAttrs: {
      src = ../../src/slock;
    });
  };
}
