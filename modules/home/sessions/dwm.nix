{
  config,
  lib,
  pkgs,
  ...
}:

# Home side of the dwm (X11) session. Monitors and wallpaper come from the
# host's vars; see modules/home/display.nix.
{
  home.packages = with pkgs; [
    # Vendored forks (overlays/vendored.nix). dwm itself is a system package:
    # the startx flow needs it on the system PATH.
    st
    slstatus

    feh
    flameshot
    xclip
    arandr
    xss-lock
    dmenu
  ];

  programs.bash = {
    enable = true;

    shellAliases = {
      copy = "xclip -selection clipboard -i";
    };

    profileExtra = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec startx "$HOME/.xsession"
      fi
    '';
  };

  xsession = {
    enable = true;

    initExtra = ''
      fcitx5 -d &
      slstatus &
      ${lib.optionalString (config.layout.xrandrArgs != "") "xrandr ${config.layout.xrandrArgs} &"}
      feh --bg-fill "$HOME/.config/wallpapers/bg.png" &
      xset s 300
      xss-lock -- slock &
      exec dwm
    '';
  };
}
