{ ... }:

# What is plugged into this machine; modules/home/display.nix turns it into the
# session's xrandr line. Connector names are the ones `xrandr -q` prints here.
{
  vars.wallpaper = ../../pics/2077.png;

  vars.outputs = {
    eDP-1 = {
      primary = true;
      order = 10;
    };
    HDMI-1-0 = {
      mode = "2560x1440";
      rate = 144;
      rightOf = "eDP-1";
      order = 20;
    };
  };
}
