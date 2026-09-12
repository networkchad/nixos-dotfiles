# Which machine runs which session; switching one is a one-word change.
#
# Each host also needs ./<name>/{configuration,home,hardware-configuration}.nix.
# A missing file fails evaluation rather than silently importing nothing.
{
  nixbox1 = {
    system = "x86_64-linux";
    users = [ "anon" ];
    session = "dwm";
  };

  nixbox2 = {
    system = "x86_64-linux";
    users = [ "anon" ];
    session = "dwl";
  };
}
