{
  config,
  lib,
  pkgs,
  ...
}:

# The X/dwm session and the apps that need one; a host imports this and fills in
# the two facts below. `vars.wallpaper` has no default on purpose: a host that
# enables the session has to say what it looks like. ly (../system/desktop.nix)
# launches what home-manager writes to `~/.xsession`.
{
  options.vars = {
    wallpaper = lib.mkOption {
      type = lib.types.path;
      example = ../../pics/2077.png;
      description = "Image linked at ~/.config/wallpapers/bg.png and set by feh.";
    };

    xrandrArgs = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "--output HDMI-0 --mode 2560x1440 --rate 144 --right-of eDP-1";
      description = ''
        Arguments for the session's one xrandr call; "" leaves the layout to X.
        Order matters: xrandr resolves --right-of only against a seen output.
      '';
    };
  };

  config = {
    home.packages = with pkgs; [
      # fcitx5 (system-wide, ../system/desktop.nix) types Japanese here, so CJK
      # fonts are not optional.
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

      pavucontrol
      mpv
      keepassxc
      brave
      librewolf

      alsa-utils # amixer: dwm's mute/volume keys
      brightnessctl # /sys/class/backlight: dwm's brightness keys

      # The session's own pieces; st and slstatus are the ../../src forks (all four
      # are defined by the overlay in ../system/forks.nix, which reaches this pkgs
      # through `useGlobalPkgs`).
      st
      slstatus
      dmenu
      feh
      flameshot
      xclip
      xss-lock
      arandr
    ];

    fonts.fontconfig.enable = true;

    # Every script here is referenced by src/slstatus/config.def.h, so a script
    # nothing names is dead by definition. They are runtime files, not build
    # inputs: the overlay filters them out of the slstatus derivation and they
    # reach the session through this link.
    xdg.configFile."slstatus/scripts" = {
      source = ../../src/slstatus/scripts;
      recursive = true;
    };
    xdg.configFile."wallpapers/bg.png".source = config.vars.wallpaper;

    # dwm needs this to reparent AWT frames like every other WM.
    home.sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";

    programs.bash = {
      # Both merge into the ones ./base.nix enables: `shellAliases` is an
      # attrsOf, so splitting the shell config across the two modules costs
      # nothing. The tty1 autostart that used to live here is gone -- ly starts
      # the session now, and a `startx` in the login shell would fight it for
      # the VT.
      shellAliases.copy = "xclip -selection clipboard -i";
    };

    # The idle policy that `xset s 300` + xss-lock used to be. A service rather
    # than a fourth `&` in the session because the module puts it under
    # graphical-session.target with `Restart = always`: a dead timer comes back on
    # its own, and the teardown below has nothing new to reap.
    #
    # The exemptions are the whole reason for the change. Nothing in nixpkgs
    # provides org.freedesktop.ScreenSaver for a bare WM, so a playing video had no
    # way to say "not now" -- the blank fired mid-video and xss-lock turned that
    # blank into a lock. `--not-when-fullscreen` reads the _NET_WM_STATE_FULLSCREEN
    # that dwm sets on a fullscreen client, `--not-when-audio` asks PulseAudio
    # (PipeWire answers for it). Those two are the only claims here a rebuild cannot
    # check: shorten `delay` once and watch whether a playing video survives it.
    #
    # Durations are seconds of inactivity, not offsets stacked on each other (see
    # `xidlehook --help`), so the panel timer follows the lock instead of preceding
    # it. No cancellers: a keystroke must never unlock, and DPMS wakes on input
    # alone.
    #
    # `slock` is the wrapper, not `${pkgs.slock}/bin/slock`, and that is not
    # cosmetic: the store binary is 0555 root:root and authenticates out of
    # /etc/shadow, which is 0640 root:shadow with the user in no shadow group, so
    # only /run/wrappers/bin/slock has the setuid bit that makes the read work.
    # Pointing the timer at the store path locks the screen and then rejects every
    # password. (`xss-lock ... -- slock` in initExtra gets this right without
    # meaning to: /run/wrappers/bin is first on the PATH the session inherits.)
    #
    # `detect-sleep` is off on purpose: it is the one thing that rewrites the
    # scheduler's idle baseline while running. xidlehook-core resets every timer to
    # *now* whenever a sleep lands >=3s late ("has the computer been suspended?"),
    # and a 300s sleep is long enough to land late -- measured on nixbox1, where
    # `xprintidle` climbed 144s -> 438s with no input and no child process while
    # the unit sat in epoll_wait and never spawned slock, and a fresh process with
    # the same flags but a 30s timer fired at once. The suspend path loses nothing:
    # a lid close is locked by xss-lock --transfer-sleep-lock below, never by
    # xidlehook.
    #
    # RUST_LOG because the binary links env_logger and every branch of that state
    # machine logs ("Triggering timer #N", the overshoot line above). A locker that
    # quietly stops firing is an unlocked laptop, so the reason has to be one
    # `journalctl --user -u xidlehook` away.
    services.xidlehook = {
      enable = true;
      not-when-audio = true;
      not-when-fullscreen = true;
      environment.RUST_LOG = "info";

      timers = [
        {
          delay = 300;
          command = "/run/wrappers/bin/slock";
        }
        {
          delay = 600;
          command = "${pkgs.xset}/bin/xset dpms force off";
        }
      ];
    };

    xsession = {
      # home-manager writes ~/.xsession, the session wrapper execs it (see
      # `windowManager.command` below for why that is not the other way round).
      enable = true;

      # Empty on purpose, and load-bearing. ly launches a session as
      # `sh -c "<setup_cmd> <session Exec>"` (auth.zig:502), and the setup
      # command is NixOS's session wrapper, whose last act is
      # `eval exec ~/.xsession "$@"`. So this script's $1 is the path of the
      # generated `none+dwm` session script, and home-manager's default
      # `test -n "$1" && eval "$@"` would run it -- a second dwm, the system
      # fallback, started the moment the real one exits. With "" the argument is
      # ignored and dwm stays the one started below.
      windowManager.command = "";

      initExtra = ''
        # No `-d`: that flag double-forks, which takes fcitx5 out of the job list
        # the teardown below kills. It then outlives the session, the next
        # session's fcitx5 finds the D-Bus name taken and exits, and what keeps
        # typing working is the previous session's daemon. Foreground + `&` is
        # the same non-blocking start, but the job is ours to kill.
        fcitx5 &
        slstatus &
        ${lib.optionalString (config.vars.xrandrArgs != "") "xrandr ${config.vars.xrandrArgs} &"}
        feh --bg-fill "$HOME/.config/wallpapers/bg.png" &
        # Off on purpose -- the service above owns idle now. `-dpms` comes with it:
        # X's own DPMS cycle is no more aware of a playing video than the screensaver
        # was, so the panel timeout moved into that chain too.
        xset s off -dpms

        # --transfer-sleep-lock hands logind's sleep inhibitor to the locker, so
        # a lid close locks on the way INTO suspend instead of resuming to a live
        # desktop -- without it, suspend never touches the X screensaver and the
        # resume is unlocked. slock works here because it never forks (no fork()
        # anywhere in ../../src/slock/slock.c; the only spawn is posix_spawnp for
        # grabbreak-command), so xss-lock can tell "locked" from "exited". slock
        # does not speak the inhibitor protocol and leaves the inherited fd open,
        # so logind falls back to its delay ceiling: lid closes, screen locks,
        # suspend follows a few seconds later. Bounded, and the end state is the
        # one we wanted. Check after the first switch: `systemctl suspend`.
        #
        # Sleep only, now. With the X screensaver off, xss-lock's idle half never
        # fires -- the xidlehook chain does the locking -- and what is left here is
        # the lid path, which never went through the screensaver anyway.
        xss-lock --transfer-sleep-lock -- slock &

        # Not `exec dwm`: home-manager appends its session teardown after this
        # block, and exec replaces the shell before any of it runs -- the next
        # session then starts with two bars and two fcitx5. Background + wait
        # keeps the shell alive for that teardown, after killing our own jobs.
        dwm &
        dwm_pid=$!
        wait "$dwm_pid" || true
        kill $(jobs -p) 2>/dev/null || true
      '';
    };
  };
}
