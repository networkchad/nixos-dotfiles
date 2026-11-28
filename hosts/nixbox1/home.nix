_: {
  imports = [ ../../modules/home/desktop.nix ];

  # Install-time compatibility baseline, not the current flake release.
  home.stateVersion = "26.05";

  vars.wallpaper = ../../pics/2077.png;

  # xrandr -q connector names, ordered so --right-of sees eDP-1 first.
  vars.xrandrArgs =
    "--output eDP-1 --auto --primary "
    + "--output HDMI-1-0 --mode 2560x1440 --rate 144 --right-of eDP-1";
}
