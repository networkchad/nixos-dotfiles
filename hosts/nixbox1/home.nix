{ ... }:

# What is plugged into this machine: connector names as `xrandr -q` prints them,
# in the order xrandr must apply them.
{
  vars.wallpaper = ../../pics/2077.png;

  vars.xrandrArgs =
    "--output eDP-1 --auto --primary "
    + "--output HDMI-1-0 --mode 2560x1440 --rate 144 --right-of eDP-1";
}
