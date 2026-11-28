{
  config,
  lib,
  pkgs,
  ...
}:

# Graphical Home Manager profile. Wallpaper is required; an empty xrandrArgs leaves
# display layout to X. The system desktop module starts the generated ~/.xsession.
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
      # Required by the system-wide fcitx5 input methods.
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

    # Runtime files named by config.def.h, deliberately excluded from the derivation.
    xdg.configFile."slstatus/scripts" = {
      source = ../../src/slstatus/scripts;
      recursive = true;
    };
    xdg.configFile."wallpapers/bg.png".source = config.vars.wallpaper;

    # Needed for Java AWT frames under dwm.
    home.sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";

    programs.bash = {
      shellAliases.copy = "xclip -selection clipboard -i";
    };

    # Bare dwm has no org.freedesktop.ScreenSaver provider, so inhibit on audio and
    # fullscreen. After changes, test with short delays; evaluation cannot verify this.
    # Timers chain: lock at 300s, then DPMS off at 600s. No canceller may unlock.
    # Use the setuid wrapper: store slock cannot read /etc/shadow and rejects passwords.
    # Keep detect-sleep off: late timers after suspend can reset idle and skip locking.
    # xss-lock handles suspend. Logging keeps lock failures visible in the user journal.
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
          delay = 300;
          command = "${pkgs.xset}/bin/xset dpms force off";
        }
      ];
    };

    xsession = {
      enable = true;

      # Load-bearing: the wrapper passes none+dwm as $1, and home-manager's default
      # would evaluate it and start a second dwm when this one exits.
      windowManager.command = "";

      initExtra = ''
        # No -d: double-forking lets fcitx5 escape teardown and block the next session.
        fcitx5 &
        slstatus &
        # Set geometry before feh measures the root window.
        ${lib.optionalString (config.vars.xrandrArgs != "") "xrandr ${config.vars.xrandrArgs}"}
        feh --bg-fill "$HOME/.config/wallpapers/bg.png" &
        # xidlehook owns idle and DPMS, including media inhibition.
        xset s off -dpms

        # Give logind's sleep inhibitor to slock, locking before suspend; slock never
        # forks, so xss-lock can track it. Suspend follows logind's delay. Idle locking
        # remains xidlehook's job.
        xss-lock --transfer-sleep-lock -- slock &

        # Do not exec: home-manager's generated teardown must kill these jobs on exit.
        dwm &
        dwm_pid=$!
        wait "$dwm_pid" || true
        kill $(jobs -p) 2>/dev/null || true
      '';
    };
  };
}
