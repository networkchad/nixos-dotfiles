{ config, lib, pkgs, ... }:

# The desktop, user half: the X-only tools and what the session starts.
# Monitors and wallpaper come from hosts/<name>/home.nix through
# modules/home/display.nix.
{
  imports = [ ./display.nix ];

  home.packages = with pkgs; [
    # Vendored forks: overlays/vendored.nix. dwm itself is a system package.
    st
    slstatus

    dmenu
    feh
    flameshot
    xclip
    xss-lock
    arandr
  ];

  programs.bash = {
    enable = true;

    shellAliases.copy = "xclip -selection clipboard -i";

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
