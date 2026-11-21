{ ... }:

# zstd compression on the /, /nix, /home subvolumes, as mount options so they merge
# into the generated `subvol=` list and hardware-configuration.nix stays untouched.
# Opt-in: a non-btrfs host omits the import. `compress`, not `compress-force`, so
# incompressible files are left raw.
#
# Write-time only, so existing data keeps its extents. To reclaim it now, defragment
# / and /home -- NOT /nix, where auto-optimise-store shares extents across half a
# million hardlinks and force-compressing them un-shares them, or aborts the
# transaction into read-only.
{
  fileSystems."/".options = [ "compress=zstd" ];
  fileSystems."/home".options = [ "compress=zstd" ];
  fileSystems."/nix".options = [ "compress=zstd" ];
}
