{ pkgs, ... }:

# System side of the dwm (X11) session.
{
  imports = [
    ../desktop/x11.nix
    ../desktop/slock.nix
  ];

  # Registers the WM and puts it on the system PATH, which the startx flow in
  # the home session needs. pkgs.dwm is the vendored fork.
  services.xserver.windowManager.dwm = {
    enable = true;
    package = pkgs.dwm;
  };

  services.picom.enable = true;
}
