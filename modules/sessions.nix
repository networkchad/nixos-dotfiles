# The system and home modules one WM stack needs, bound together so that a
# session name in the host table always means both halves.
{
  dwm = {
    system = ./nixos/sessions/dwm.nix;
    home = ./home/sessions/dwm.nix;
  };

  dwl = {
    system = ./nixos/sessions/dwl.nix;
    home = ./home/sessions/dwl.nix;
  };
}
