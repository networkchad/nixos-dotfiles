# Local forks of the tools in ../src. Their patches are carried in the source
# (provenance: ../patches/README.md), so upstream's `patches` are dropped --
# they would be applied to code we already modified by hand.
#
# The `-local` version suffix keeps a fork rebuild visible in nixos-rebuild
# output; without it a fork is name-identical to upstream.
final: prev:
let
  # prev, not final: forcing final.lib from inside an overlay recurses.
  inherit (prev.lib) cleanSource genAttrs;
  vendorSrc = ../src;
in
genAttrs [
  "dwm"
  "st"
  "slstatus"
  "slock"
] (
  name:
  prev.${name}.overrideAttrs (
    old:
    {
      version = "${old.version}-local";
      src = cleanSource (vendorSrc + /${name});
      patches = [ ];
    }
  )
)
