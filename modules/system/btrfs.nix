{ ... }:

# zstd compression on the three btrfs subvolumes the installer makes: /, /nix,
# /home. Declared as mount options here rather than in each host's
# ./hosts/<name>/hardware-configuration.nix -- which nixos-generate-config owns
# and nobody hand-edits -- because `fileSystems.<mount>.options` is a list, so
# these append to the generated `subvol=` options instead of replacing them. A
# host that is not on btrfs simply does not import this file.
#
# `compress=zstd` is the kernel default level (3): near-free CPU on a laptop, and
# the level the number below was measured at. Measured on nixbox1's store -- every
# unique inode (auto-optimise-store had already hardlinked the byte-identical
# dupes), zstd -3 per file, incompressible files capped raw the way btrfs does:
# 9.78 GiB of /nix/store -> ~4.5 GiB, ~5.3 GiB back, 57% on the >=2 MiB files that
# carry two-thirds of the bytes. The small-file tier is looser (a 4 KiB extent
# floor eats part of it), so the honest all-round figure is ~50%.
#
# Two things the option alone does not say, so they are said here:
#
#   * Compression is write-time only. It shrinks data written after the switch;
#     what is already on disk keeps its current extents until rewritten. To
#     capture it now, once per host:
#         sudo btrfs filesystem defragment -r -v -czstd / /home /nix
#     Otherwise `nix gc` + rebuilds churn /nix over time and it fills in by itself.
#
#   * `compress-force` is deliberately NOT used: it also compresses the files
#     that grow, paying CPU for nothing. Plain `compress` gives up on those after
#     one failed attempt and stores them uncompressed.
{
  fileSystems."/".options = [ "compress=zstd" ];
  fileSystems."/home".options = [ "compress=zstd" ];
  fileSystems."/nix".options = [ "compress=zstd" ];
}
