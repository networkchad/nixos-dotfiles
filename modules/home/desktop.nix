{
  config,
  lib,
  pkgs,
  ...
}:

# The X/dwm session and the apps that need one; a host imports this and fills in the
# two options below. `vars.wallpaper` has no default on purpose: a host that enables
# the session says what it looks like. ly (../system/desktop.nix) launches what
# home-manager writes to `~/.xsession`.
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
      # fcitx5 (system-wide, ../system/desktop.nix) types Japanese here, so CJK fonts
      # are not optional.
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

      # The session's own pieces; st and slstatus are the ../../src forks, which reach
      # this pkgs through the overlay in ../system/forks.nix.
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

    # Every script here is named by src/slstatus/config.def.h, and they are runtime
    # files rather than build inputs -- the overlay filters them out of the slstatus
    # derivation, so this link is how they reach the session.
    xdg.configFile."slstatus/scripts" = {
      source = ../../src/slstatus/scripts;
      recursive = true;
    };
    xdg.configFile."wallpapers/bg.png".source = config.vars.wallpaper;

    # dwm needs this to reparent AWT frames like every other WM.
    home.sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";

    programs.bash = {
      # Merges into the ones ./base.nix enables: `shellAliases` is an attrsOf, so
      # splitting the shell config across the two modules costs nothing.
      shellAliases.copy = "xclip -selection clipboard -i";
    };

    # The idle policy `xset s 300` + xss-lock used to be, as a service under
    # graphical-session.target with `Restart = always`: a dead timer comes back.
    #
    # The exemptions are the whole reason for the change. Nothing in nixpkgs provides
    # org.freedesktop.ScreenSaver for a bare WM, so a playing video had no way to say
    # "not now" -- the blank fired mid-video and xss-lock turned it into a lock.
    # `--not-when-fullscreen` reads the _NET_WM_STATE_FULLSCREEN dwm sets,
    # `--not-when-audio` asks PulseAudio (PipeWire answers for it). The two claims a
    # rebuild cannot check: shorten `delay` and see whether a video survives it.
    #
    # Durations are seconds of inactivity, not offsets stacked on each other, so the
    # panel timer follows the lock. No cancellers: a keystroke must never unlock.
    #
    # /run/wrappers/bin/slock, not `${pkgs.slock}/bin/slock`. The store binary is
    # 0555 root:root and reads /etc/shadow, which is 0640 root:shadow with this user in
    # no shadow group, so only the wrapper has the setuid bit that makes the read
    # work -- the store path locks the screen and then rejects every password.
    #
    # `detect-sleep` is off on purpose: it rewrites the idle baseline, resetting every
    # timer to *now* whenever a sleep lands >=3s late, and a 300s sleep is long enough
    # to land late. That is how the locker here stopped firing while the laptop sat
    # unlocked. The suspend path loses nothing: a lid close is locked by xss-lock
    # below, never by xidlehook.
    #
    # RUST_LOG because the binary links env_logger and every branch of that state
    # machine logs. A locker that quietly stops firing is an unlocked laptop, so the
    # reason has to be one `journalctl --user -u xidlehook` away.
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
      # home-manager writes ~/.xsession and the session wrapper execs it -- see
      # `windowManager.command` for why that is not the other way round.
      enable = true;

      # Empty on purpose, and load-bearing. The wrapper's last act is
      # `eval exec ~/.xsession "$@"`, where $1 is the path of the generated `none+dwm`
      # script; home-manager's default `test -n "$1" && eval "$@"` would run it -- a
      # second dwm, from the system fallback, at the moment the real one exits.
      windowManager.command = "";

      initExtra = ''
        # No `-d`: that flag double-forks, which takes fcitx5 out of the job list the
        # teardown below kills. It then outlives the session, the next session's
        # fcitx5 finds the D-Bus name taken and exits, and what keeps typing working is
        # the previous session's daemon.
        fcitx5 &
        slstatus &
        ${lib.optionalString (config.vars.xrandrArgs != "") "xrandr ${config.vars.xrandrArgs} &"}
        feh --bg-fill "$HOME/.config/wallpapers/bg.png" &
        # The service above owns idle now, X's own DPMS cycle included: it is no more
        # aware of a playing video than the screensaver was.
        xset s off -dpms

        # --transfer-sleep-lock hands logind's sleep inhibitor to the locker, so a lid
        # close locks on the way INTO suspend instead of resuming to a live desktop.
        # slock qualifies because it never forks, so xss-lock can tell "locked" from
        # "exited"; it does not speak the inhibitor protocol, so logind falls back to
        # its delay ceiling -- suspend follows a few seconds after the lock.
        #
        # Sleep only: with the X screensaver off, xss-lock's idle half never fires and
        # the xidlehook chain does the locking.
        xss-lock --transfer-sleep-lock -- slock &

        # Not `exec dwm`: home-manager appends its session teardown after this block,
        # and exec replaces the shell before any of it runs -- the next session would
        # start with two bars and two fcitx5.
        dwm &
        dwm_pid=$!
        wait "$dwm_pid" || true
        kill $(jobs -p) 2>/dev/null || true
      '';
    };
  };
}
