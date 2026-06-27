{ pkgs, ... }:

{
  imports = [
    ../pkgs/st.nix
    ../pkgs/slstatus.nix
  ];

  services.picom.enable = true;

  home.packages = with pkgs; [
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
    loginExtra = ''
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
    '';
  };
}
