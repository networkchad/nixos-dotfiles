{ pkgs, ... }:

# The desktop, system half: X on tty1, dwm as the WM, picom for transparency,
# slock to lock. The user half (what the session starts) is
# modules/home/desktop.nix.
{
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;

    # No display manager: login stays on the tty and `startx` starts dwm.
    displayManager.startx.enable = true;

    # The vendored fork (overlays/vendored.nix), on the system PATH because
    # startx is what execs it.
    windowManager.dwm = {
      enable = true;
      package = pkgs.dwm;
    };
  };

  services.picom.enable = true;

  # pkgs.slock is the vendored fork.
  programs.slock.enable = true;
}
