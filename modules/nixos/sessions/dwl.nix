{ ... }:

# System side of the dwl (Wayland) session.
# Note: idle/sleep locking is done by the `swayidle ... swaylock -fF` line in
# dwl's autostart (src/dwl/config.def.h); nixpkgs ships no swayidle module.
# The `swayidle` binary itself comes from the home session package list.
{
  imports = [
    ../wayland.nix
  ];
}
