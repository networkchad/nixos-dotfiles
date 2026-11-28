{ ... }:

# Mount options merge with the generated subvolume settings. `compress` skips
# incompressible data, unlike `compress-force`, and affects only new writes.
# Never defragment /nix to compress old data: that unshares the store's hardlinked
# extents and can fail the transaction. Defragment only / and /home if needed.
{
  fileSystems."/".options = [ "compress=zstd" ];
  fileSystems."/home".options = [ "compress=zstd" ];
  fileSystems."/nix".options = [ "compress=zstd" ];

  # The root mount scrubs the entire filesystem, including /home and /nix.
  # This verifies checksums and repairs redundant copies; it is not a backup.
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
    interval = "monthly";
  };
}
