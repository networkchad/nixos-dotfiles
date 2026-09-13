{
  config,
  lib,
  pkgs,
  ...
}:

# The user half, shared by every host: apps, shell, and what the session
# starts. Identity comes from the host table in ../flake.nix; the two options
# below are filled in by ./<name>/home.nix.
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
      alsa-utils
      uv
      devenv
      dysk
      brave
      librewolf
      pi-coding-agent

      # Vendored forks (overlay in ./common.nix); dwm is a system package.
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

    # slstatus reads its bar segments from here (src/slstatus/config.def.h).
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

    xsession = {
      enable = true;

      initExtra = ''
        fcitx5 -d &
        slstatus &
        ${lib.optionalString (config.vars.xrandrArgs != "") "xrandr ${config.vars.xrandrArgs} &"}
        feh --bg-fill "$HOME/.config/wallpapers/bg.png" &
        xset s 300
        xss-lock -- slock &
        exec dwm
      '';
    };
  };
}
