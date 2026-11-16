{ ... }:

# zstd compression on the /, /nix, /home btrfs subvolumes. Set as mount options so
# they merge into the generated `subvol=` list and hardware-configuration.nix
# stays untouched. Opt-in -- a non-btrfs host omits the import. `compress`, not
# `compress-force`, so incompressible files are left raw.
#
# Compression is write-time only, so data already on disk keeps its extents. To
# reclaim it now, defragment / and /home -- but NOT /nix: auto-optimise-store
# shares extents across half a million hardlinks, and force-compressing shared
# extents un-shares them (or aborts the transaction into read-only). /nix
# compresses on its own as nix gc and rebuilds rewrite it.
{
  fileSystems."/".options = [ "compress=zstd" ];
  fileSystems."/home".options = [ "compress=zstd" ];
  fileSystems."/nix".options = [ "compress=zstd" ];
}
