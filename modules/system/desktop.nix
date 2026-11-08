{ pkgs, ... }:

# The graphical half of a host: ly on tty1, dwm, picom, slock, plus the sound
# and input-method layers that session needs. A host that never shows a desktop
# does not import this file -- and the keymap (`services.xserver.xkb.layout`,
# left to the host file) is the one thing here it has to state.
{
  imports = [ ./forks.nix ]; # dwm and slock are the ../../src forks

  # The X server. ly starts it through `services.xserver.displayManager`'s
  # xserverBin/xserverArgs -- its `x_cmd` is a wrapper around exactly those
  # (`exec systemd-cat -t xserver-wrapper ${xserverBin} ${xserverArgs}`) -- so
  # the startx pseudo-DM and the /etc/X11/xinit/xserverrc it existed to provide
  # both leave with the tty autostart.
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;

    # The startx module used to set this. Without it /etc/X11/xorg.conf stops
    # being written, and the PRIME `BusID`s hardware.nvidia generates land only
    # in that file -- xorg.conf.d here holds just 00-keyboard.conf and the
    # evdev/libinput classes (checked on nixbox1) -- so dropping it would have
    # quietly taken `nvidia-offload` down with it.
    exportConfiguration = true;

    # Two jobs: the session entry ly lists (see `defaultSession` below) and the
    # fork on the PATH. Its own start line (`dwm &`, plus
    # _JAVA_AWT_WM_NONREPARENTING) is only the fallback -- the session wrapper
    # execs ~/.xsession before it, so the session that actually runs is the one
    # home-manager writes (../../modules/home/desktop.nix).
    windowManager.dwm.enable = true;
  };

  # ly on tty1 replaces the `startx` line the login shell used to run: same VT,
  # same password, but what it starts is a real logind session (own scope,
  # XDG_SESSION_TYPE=x11, PAM service `ly`) instead of X inside the getty
  # session, and quitting dwm returns to the greeter instead of a login prompt.
  #
  # `services.displayManager.autoLogin` stays off on purpose: the login password
  # is what stands between a closed lid and the desktop, and that is the one
  # property the tty autostart had which a display manager gives up for free.
  services.displayManager = {
    ly = {
      enable = true;

      settings = {
        # ly 1.4's username box is not a text field: `UserList` is a
        # CyclableLabel over getAllUsernames() -- every uid inside login.defs'
        # range, plus root always -- so a name is always on screen and the list
        # is not filterable. What `save = false` does buy: the box no longer
        # opens on the last user (and the session they last picked), and ly
        # stops writing /etc/ly/save.txt, which is exactly that -- last username
        # plus session index, in the clear, under /etc.
        save = false;

        # The "Shell" row is not a shell on NixOS. ly runs
        # `$SHELL -c "<setup_cmd> <shell>"` for it (auth.zig:557) and
        # `setup_cmd` is this file's session wrapper, whose
        # `test -x ~/.xsession` branch then execs the dwm session. So the row
        # would be a second, misleading dwm entry; a real shell is Ctrl+Alt+F2
        # -- logind instantiates autovt@tty2 -> a getty that ly does not own
        # (its unit only conflicts with autovt@tty1) and that works with X and
        # with ly themselves wedged.
        shell = false;
      };
    };

    # The .desktop entry ly offers. The module that generates those names it
    # "<desktopManager>+<windowManager>", so this is the one dwm registers; a
    # typo here is an eval error, not a greeter with an empty list.
    defaultSession = "none+dwm";
  };

  # Manuals are the largest thing in the closure that a dwm session never reads:
  # every `-doc` output of the GTK/fcitx5/pavucontrol stack (kdoctools alone
  # accounts for 775 MiB of the 10.3 GiB this system closes to) plus the NixOS
  # manual and the info pages. `man` stays on -- it is the only one of the three
  # that is usable from st.
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

    # Compositing exists here for exactly one feature: st's alpha
    # (../../src/st/config.def.h) needs a redirect-and-repaint WM. The module
    # default -- xrender with vsync off -- pays that tax and still tears, and
    # picom's own documented pairing for vsync is the glx backend.
    #
    # glx is safe on both boxes because PRIME offload puts the *session* on the
    # iGPU (nixbox1: `intel_backlight` under card1/eDP-1, so modesetting drives
    # the panel and composites too) -- picom never touches the blob. If it ever
    # does, the rollback is `backend = "xrender"` plus
    # `settings.xrender-sync-fence = true`, which is picom's own note for
    # nvidia-drivers with the GLX backend.
    #
    # unredir-if-possible hands a fullscreen window back to the X server, so
    # games don't sit behind picom's swap chain (it already happens for DPMS
    # power-off, this is the same mechanism for fullscreen).
    backend = "glx";
    vSync = true;
    settings.unredir-if-possible = true;
  };

  # Both machines are laptops. This pins the behavior they already have rather
  # than fixing a bug: NixOS sets none of these (verified: the generated
  # /etc/systemd/logind.conf carries only KillUserProcesses, and logind reports
  # suspend / "" / ignore through busctl), and upstream has moved these defaults
  # before. Empty HandleLidSwitchExternalPower means "not used", so on AC the
  # HandleLidSwitch action applies anyway -- writing "suspend" keeps that
  # behavior and says it out loud. Closed lid on battery suspends; closed lid on
  # the dock (a second output counts as docked) keeps running on HDMI.
  #
  # Locking on the way into suspend is the session's job, not logind's --
  # ../../modules/home/desktop.nix passes the sleep lock to slock through
  # xss-lock.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  # dwm on the PATH rides along with services.xserver.windowManager.dwm above
  # (`environment.systemPackages = [ cfg.package ]`, and `cfg.package` is the
  # overlaid fork), so nothing to repeat here.
}
