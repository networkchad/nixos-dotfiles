# Local forks of the tools in ../src. Their patches are carried in the source
# (provenance: ../patches/README.md), so upstream's `patches` are dropped --
# they would be applied to code we already modified by hand.
#
# The `-local` version suffix keeps a fork rebuild visible in nixos-rebuild
# output; without it a fork is name-identical to upstream.
final: prev:
let
  inherit (final.lib) cleanSource;
  vendorSrc = ../src;

  fork =
    name: extra:
    prev.${name}.overrideAttrs (
      old:
      {
        version = "${old.version}-local";
        src = cleanSource (vendorSrc + /${name});
        patches = [ ];
      }
      // extra old
    );
in
{
  dwl = fork "dwl" (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [
      final.fcft
      final.libdrm
    ];
  });

  dwm = fork "dwm" (_: { });
  st = fork "st" (_: { });
  slstatus = fork "slstatus" (_: { });
  slock = fork "slock" (_: { });
}
