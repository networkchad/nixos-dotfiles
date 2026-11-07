{ pkgs, ... }:

# The graphical half of a host: X on tty1, dwm, picom, slock, plus the sound and
# input-method layers that session needs. A host that never shows a desktop does
# not import this file -- and the keymap (`services.xserver.xkb.layout`, left to
# the host file) is the one thing here it has to state.
{
  imports = [ ./forks.nix ]; # dwm and slock are the ../../src forks

  # X on tty1, dwm, picom, slock. No display manager: login stays on the tty.
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    displayManager.startx.enable = true;
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

  # dwm is on the PATH because home-manager's ~/.xsession runs it. Not
  # services.xserver.windowManager.dwm: that only registers a display-manager
  # session, which the startx pseudo-DM never reads.
  environment.systemPackages = [ pkgs.dwm ];
}
