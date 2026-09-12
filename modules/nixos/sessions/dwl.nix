{
  # System side of the dwl (Wayland) session.
  #
  # Locking is the `swayidle ... swaylock -fF` entry in dwl's autostart, and
  # monitor layout comes from the host's vars.outputs as
  # ~/.config/session/display.sh, which that same autostart runs.
  imports = [ ../desktop/wayland.nix ];
}
