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
    
    windowManager.command = "exec dwm";

    initExtra = ''
      fcitx5 -d &
      slstatus &
      feh --bg-fill $HOME/.config/wallpapers/bg.png &
      xset s 300
      xss-lock -- slock &
    '';
  };
}
