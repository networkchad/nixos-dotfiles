{ ... }:

# Built-in panel only, so no xrandr line: X uses the panel's preferred mode.
# To add a monitor, e.g.
#   vars.xrandrArgs = "--output HDMI-0 --mode 2560x1440 --rate 144";
{
  vars.wallpaper = ../../pics/nix-wallpaper-dracula.png;
}
