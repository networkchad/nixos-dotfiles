_:

# The session is ../../modules/home/desktop.nix; only the facts differ per host.
# Built-in panel only here, so no xrandr line: X keeps the panel's preferred mode.
{
  imports = [ ../../modules/home/desktop.nix ];

  vars.wallpaper = ../../pics/nix-wallpaper-dracula.png;
}
