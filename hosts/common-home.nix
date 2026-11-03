{
  config,
  lib,
  pkgs,
  ...
}:

# The user profile every host shares; ./<name>/home.nix fills in `vars`, and
# identity comes from the host table in ../flake.nix.
{
  options.vars = {
    wallpaper = lib.mkOption {
      type = lib.types.path;
      example = ../pics/2077.png;
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
    home.stateVersion = "26.05";

    home.packages = with pkgs; [
      # fcitx5 types Japanese here, so CJK fonts are not optional.
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

      pavucontrol
      mpv
      fastfetch
      keepassxc
      alsa-utils # amixer: dwm's mute/volume keys
      brightnessctl # /sys/class/backlight: dwm's brightness keys
      uv
      devenv
      dysk
      brave
      librewolf
      pi-coding-agent

      # X session bits; st and slstatus are the ../src forks (all four are
      # defined by the overlay in ./common-configuration.nix), dwm is a system
      # package because ~/.xsession runs it.
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
      source = ../src/slstatus/scripts;
      recursive = true;
    };
    xdg.configFile."wallpapers/bg.png".source = config.vars.wallpaper;

    programs = {
      home-manager.enable = true;
      btop.enable = true;

      vim = {
        enable = true;
        extraConfig = ''
          syntax on
          set number
        '';
      };

      bash = {
        enable = true;

        shellAliases.copy = "xclip -selection clipboard -i";

        # No display manager: the session starts from the login shell on tty1.
        profileExtra = ''
          if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
            exec startx "$HOME/.xsession"
          fi
        '';
      };
    };

    # dwm needs this to reparent AWT frames like every other WM.
    home.sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";

    xsession = {
      enable = true;

      initExtra = ''
        fcitx5 -d &
        slstatus &
        ${lib.optionalString (config.vars.xrandrArgs != "") "xrandr ${config.vars.xrandrArgs} &"}
        feh --bg-fill "$HOME/.config/wallpapers/bg.png" &
        xset s 300

        # --transfer-sleep-lock hands logind's sleep inhibitor to the locker, so
        # a lid close locks on the way INTO suspend instead of resuming to a live
        # desktop -- without it, suspend never touches the X screensaver and the
        # resume is unlocked. slock works here because it never forks (no fork()
        # anywhere in ../src/slock/slock.c; the only spawn is posix_spawnp for
        # grabbreak-command), so xss-lock can tell "locked" from "exited". slock
        # does not speak the inhibitor protocol and leaves the inherited fd open,
        # so logind falls back to its delay ceiling: lid closes, screen locks,
        # suspend follows a few seconds later. Bounded, and the end state is the
        # one we wanted. Check after the first switch: `systemctl suspend`.
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
