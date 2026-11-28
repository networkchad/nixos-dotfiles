{ lib, ... }:

# Define the four local forks once; useGlobalPkgs shares them with Home Manager.
# Bases are upstream Git trees, so inherited nixpkgs release-tarball patches are cleared.
# config.mk supplies the real tree version; -local makes fork rebuilds visible.
# See ../../patches/README.md for provenance and rebasing.
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
            # Include only build inputs. Runtime scripts and nearby docs cannot trigger rebuilds.
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
