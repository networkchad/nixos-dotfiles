{ pkgs, ... }:

# The graphical half of a host: ly on tty1, dwm, picom, slock, plus the sound and
# input-method layers the session needs. A host that never shows a desktop does not
# import this file -- and the keymap (`services.xserver.xkb.layout`) is the one fact
# it has to state for itself.
{
  imports = [ ./forks.nix ]; # dwm and slock are the ../../src forks

  # ly starts X through displayManager's xserverBin/xserverArgs, which is also what
  # tags it `xserver-wrapper` in the journal.
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;

    # The PRIME `BusID`s hardware.nvidia generates land only in /etc/X11/xorg.conf,
    # not in xorg.conf.d, so turning this off takes `nvidia-offload` down with it.
    exportConfiguration = true;

    # Two jobs: the session entry ly lists (see `defaultSession`) and the fork on the
    # PATH. Its own start line is only the fallback -- the session wrapper execs
    # ~/.xsession first (../../modules/home/desktop.nix).
    windowManager.dwm.enable = true;
  };

  # ly on tty1 in place of the `startx` the login shell used to run: same VT, same
  # password, but a real logind session (own scope, XDG_SESSION_TYPE=x11, PAM service
  # `ly`), and quitting dwm returns to the greeter.
  #
  # `services.displayManager.autoLogin` stays off on purpose: the login password is
  # what stands between a closed lid and the desktop, the one property the tty
  # autostart had that a display manager gives up for free.
  services.displayManager = {
    ly = {
      enable = true;

      settings = {
        # ly's username box is not a text field but a cyclable list over every uid in
        # login.defs' range plus root, so it cannot be filtered. What `save = false`
        # does buy is the prefill with the last user -- and stops ly writing
        # /etc/ly/save.txt, which is that same pair in the clear, under /etc.
        save = false;

        # Not a shell on NixOS: ly runs `$SHELL -c "<setup_cmd> <shell>"` for it, and
        # setup_cmd is the wrapper above, which execs the dwm session. So the row is a
        # second, misleading dwm. A real shell is Ctrl+Alt+F2 -- logind instantiates
        # autovt@tty2, and ly's unit conflicts only with autovt@tty1 -- which still
        # works with X or ly themselves wedged.
        shell = false;
      };
    };

    # The .desktop entry ly offers; the module that generates them names it
    # "<desktopManager>+<windowManager>", so this is the one dwm registers.
    defaultSession = "none+dwm";
  };

  # Manuals are the largest thing in the closure that a dwm session never reads:
  # every `-doc` output of the GTK/fcitx5/pavucontrol stack, the NixOS manual and the
  # info pages. `man` stays -- the only one of the three usable from st.
  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  # Typed through fcitx5 on both machines, so system-wide, not per session.
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-chewing
    ];
  };

  # pipewire and its compat layers come from the X server's defaults; rtkit's
  # realtime flag is read by pipewire but not set by them.
  security.rtkit.enable = true;
  services.pipewire.alsa.support32Bit = true; # Steam/Wine/old games

  programs.slock.enable = true;

  services.picom = {
    enable = true;

    # Compositing exists here for one feature: st's alpha (../../src/st/config.def.h)
    # needs a redirect-and-repaint WM. The module default pays that tax and still
    # tears, and picom's documented pairing for vsync is glx.
    #
    # glx is safe because PRIME offload puts the *session* on the iGPU, so picom
    # never touches the blob. If it ever does, the rollback is `backend = "xrender"`
    # plus `settings.xrender-sync-fence = true`.
    #
    # unredir-if-possible hands a fullscreen window back to the X server, so games
    # don't sit behind picom's swap chain.
    backend = "glx";
    vSync = true;
    settings.unredir-if-possible = true;
  };

  # Both machines are laptops, and NixOS sets none of these. Closed lid on battery
  # suspends; closed lid on the dock (a second output counts as docked) keeps running
  # on HDMI -- empty HandleLidSwitchExternalPower means "not used", so spelling out
  # "suspend" keeps the behavior and says it out loud.
  #
  # Locking on the way into suspend is the session's job, not logind's --
  # ../../modules/home/desktop.nix hands the sleep lock to slock through xss-lock.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  # dwm on the PATH rides along with services.xserver.windowManager.dwm above, from
  # the overlaid package set.
}
