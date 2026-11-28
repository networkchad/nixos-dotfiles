{ ... }:

# Compressed RAM swap for hosts without disk swap; this cannot support hibernation.
{
  zramSwap.enable = true;
}
