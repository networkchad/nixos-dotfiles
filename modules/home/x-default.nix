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

  xsession.enable = true;

  xsession.initExtra = ''
    fcitx5 -d &
    slstatus &
    xrandr --auto
    feh --bg-fill $HOME/.config/wallpapers/2077.png &
    xset s 300
    xss-lock -- slock &
  '';
}
