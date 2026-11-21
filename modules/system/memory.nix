{ ... }:

# A zstd-compressed swap device in RAM. These hosts run swapless, so a spike has
# nowhere to go and the OOM killer fires late on a frozen box. Opt-in like
# ./btrfs.nix. Not hibernate -- that needs swap on disk.
{
  zramSwap.enable = true;
}
