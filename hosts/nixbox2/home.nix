{ ... }:

# What is plugged into this machine; sessions read it through display.nix.
{
  vars.wallpaper = ../../pics/nix-wallpaper-dracula.png;

  # Built-in panel only; wlroots uses its preferred mode. When something is
  # plugged in, add e.g.
  #   vars.outputs.HDMI-A-2 = { mode = "2560x1440"; rate = 144; order = 20; };
  vars.outputs = { };
}
