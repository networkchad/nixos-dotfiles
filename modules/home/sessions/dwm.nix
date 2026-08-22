{ pkgs, ... }:

{
  imports = [
    ../packages/st.nix
    ../packages/slstatus.nix
  ];

  home.packages = with pkgs; [
    feh
    flameshot
    xclip
    arandr
    xss-lock
    dmenu
  ];

  programs.yazi.settings.opener.image_viewer = [
    {
      run = "${pkgs.feh}/bin/feh --start-at \"$1\" .";
      desc = "View Image Directory";
    }
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
      xrandr --output eDP-1 --auto --primary --output HDMI-1-0 --mode 2560x1440 --rate 144 --right-of eDP-1 &
      feh --bg-fill $HOME/.config/wallpapers/bg.png &
      xset s 300
      xss-lock -- slock &
      exec dwm
    '';
  };
}
