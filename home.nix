{ config, pkgs, ... }:

{
  home.username = "anon";
  home.homeDirectory = "/home/anon";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    dmenu
    firefox
    ani-cli
    pavucontrol
    brightnessctl
    mpv
    feh
    flameshot
    xclip
    fastfetch
    keepassxc
    btop
    brave
    uv
    arandr
    alsa-utils
    lshw
    xautolock
    ledger-live-desktop
    (st.overrideAttrs (oldAttrs: {
      src = ./config/st;
    }))
    (dwmblocks.overrideAttrs (oldAttrs: {
      src = ./config/dwmblocks;
    }))
  ];

  programs.vim = {
    enable = true;
    extraConfig = ''
      syntax on
      set number
    '';
  };

  xsession.enable = true;
  xsession.initExtra = ''
    fcitx5 -d &
    dwmblocks &
    sleep 0.25
    xrandr --output eDP-1 --auto --primary --output HDMI-1-0 --mode 2560x1440 --rate 144 --right-of eDP-1
    feh --bg-fill $HOME/nixos-dotfiles/pics/wallpaper.png &
    xautolock -time 5 -locker /run/wrappers/bin/slock -corners 0-00 &
  '';

  programs.bash = {
    enable = true;
    shellAliases = {
      xclip = "xclip -selection clipboard -i";
    };
  };

}
