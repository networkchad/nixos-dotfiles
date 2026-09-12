{ ... }:

# What is plugged into this machine; modules/home/display.nix turns it into the
# session's xrandr line. Connector names are the ones `xrandr -q` prints here.
{
  vars.wallpaper = ../../pics/nix-wallpaper-dracula.png;

  # Built-in panel only, so no xrandr line at all: X uses the panel's preferred
  # mode. When something is plugged in, add e.g.
  #   vars.outputs.HDMI-0 = { mode = "2560x1440"; rate = 144; order = 20; };
  vars.outputs = { };
}
