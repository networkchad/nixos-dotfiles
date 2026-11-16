{ ... }:

# zramSwap: a zstd-compressed swap device living in RAM. The laptops run swapless,
# so a memory spike has nowhere to go and the OOM killer fires late on a frozen
# box; zram raises the ceiling so cold pages compress instead. No disk, no
# partition, no btrfs-swapfile fuss. Not hibernate -- that needs swap on disk.
# Opt-in like ./btrfs.nix: a host that wants no zram device just omits the import.
{
  zramSwap.enable = true;
}
