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
  };

  xsession = {
    enable = true;
    
    initExtra = ''
      fcitx5 -d &
      slstatus &
      xrandr --output eDP-1 --auto --primary --output HDMI-1-0 --mode 3840x2160 --rate 60 --right-of eDP-1 &
      feh --bg-fill $HOME/.config/wallpapers/bg.png &
      xset s 300
      xss-lock -- slock &
    '';
  };
}
