{ lib, ... }:

# All four ../../src forks, defined once here and pulled in by ./desktop.nix,
# which is the module that needs them: dwm and slock from the system side, st and
# slstatus from the home side (home-manager's `useGlobalPkgs` hands it this same
# overlaid package set). The per-host files never mention a fork.
#
# Upstream's `patches` are dropped: the hunks are already in the tree, and
# upstream's list applies to the release tarball these trees were forked from
# (../../patches/README.md pins each base commit and lists what is actually
# local). `version` is read from src/<name>/config.mk because `old.version` would
# name a tree this derivation does not build, and `-local` keeps a fork rebuild
# visible in nixos-rebuild output.
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
            # Exactly what the Makefile reads: the sources, the two config files
            # it builds against, and the man page (+ st's terminfo) it installs.
            # LICENSE, README, FAQ and src/slstatus/scripts stay in the repo but
            # out of the derivation, so editing one cannot rebuild a fork.
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
