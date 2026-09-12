# The machine list. Every entry needs ./<name>/{configuration,home,hardware-configuration}.nix;
# a missing file, or a missing `system`/`users` key, fails evaluation rather than
# silently importing nothing.
{
  nixbox1 = {
    system = "x86_64-linux";
    users = [ "anon" ];
  };

  nixbox2 = {
    system = "x86_64-linux";
    users = [ "anon" ];
  };
}
