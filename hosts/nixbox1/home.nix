{ config, pkgs, ... }:

{
  home.username = "anon";
  home.homeDirectory = "/home/anon";
  home.stateVersion = "26.05";

  services.picom.enable = true;

  home.packages = with pkgs; [
    dmenu
    ani-cli
    pavucontrol
    brightnessctl
    mpv
    feh
    flameshot
    xclip
    fastfetch
    keepassxc
    brave
    uv
    arandr
    alsa-utils
    lshw
    xautolock
    ledger-live-desktop
    (st.overrideAttrs (oldAttrs: {
      src = ../../modulespkgs/suckless/st;
    }))
    (dwmblocks.overrideAttrs (oldAttrs: {
      src = ../../modules/pkgs/suckless/dwmblocks;
    }))
  ];

  programs = {
    home-manager.enable = true;
    firefox.enable = true;
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
      shellAliases = {
        xclip = "xclip -selection clipboard -i";
      };
    };
  };

  xsession.enable = true;
  xsession.initExtra = ''
    fcitx5 -d &
    dwmblocks &
    xrandr --output eDP-1 --auto --primary --output HDMI-1-0 --mode 2560x1440 --rate 144 --right-of eDP-1
    feh --bg-fill $HOME/nixos-dotfiles/pics/wallpaper.png &
    xautolock -time 5 -locker /run/wrappers/bin/slock -corners 0-00 &
  '';
}
