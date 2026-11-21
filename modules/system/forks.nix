{ lib, ... }:

# The four ../../src forks, defined once here and pulled in by ./desktop.nix, the
# module that needs them: dwm and slock from the system side, st and slstatus from
# the home side (`useGlobalPkgs` hands it this same overlaid package set).
#
# Upstream's `patches` are dropped: the hunks are already in the tree and upstream's
# list applies to the release tarball these were forked from. `version` is read from
# src/<name>/config.mk, because `old.version` would name a tree this derivation does
# not build, and `-local` keeps a fork rebuild visible in nixos-rebuild output. See
# ../../patches/README.md for the base commits.
{
  nixpkgs.overlays = [
    (
      _final: prev:
      lib.genAttrs
        [
          "dwm"
          "st"
          "slstatus"
          "slock"
        ]
        (
          name:
          let
            lines = lib.splitString "\n" (builtins.readFile (../../src + /${name}/config.mk));
            line =
              lib.findFirst (lib.hasPrefix "VERSION")
                (throw "src/${name}/config.mk has no `VERSION = <version>` line")
                lines;
          in
          prev.${name}.overrideAttrs (_: {
            version = "${lib.trim (builtins.head (builtins.match "VERSION = +(.*)" line))}-local";
            # Exactly what the Makefile reads -- sources, the two config files, the
            # man page (+ st's terminfo). LICENSE, README, FAQ and scripts/ stay in
            # the repo but out of the derivation, so editing one cannot rebuild a fork.
            src = lib.cleanSourceWith {
              src = ../../src + /${name};
              filter =
                path: type:
                type == "directory"
                || lib.any (suffix: lib.hasSuffix suffix path) [
                  ".c"
                  ".h"
                  ".1"
                ]
                || lib.elem (baseNameOf path) [
                  "Makefile"
                  "config.mk"
                  "config.def.h"
                  "st.info"
                ];
            };
            patches = [ ];
          })
        )
    )
  ];
}
