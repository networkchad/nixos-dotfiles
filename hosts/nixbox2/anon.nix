{ config, pkgs, ... }:

{
  home.username = "anon";
  home.homeDirectory = "/home/anon";
  home.stateVersion = "26.05";

  xdg.configFile."dwmblocks/scripts" = {
    source = ../../modules/pkgs/dwmblocks/scripts;
    recursive = true;
  };
  
  xdg.configFile."wallpapers/wallpaper1.png".source = ../../pics/wallpaper1.png;

  services.picom.enable = true;

  home.packages = with pkgs; [
    dmenu
    ani-cli
    pavucontrol
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
    xautolock
    ledger-live-desktop
    (st.overrideAttrs (oldAttrs: {
      src = ../../modules/pkgs/st;
    }))
    (dwmblocks.overrideAttrs (oldAttrs: {
      src = ../../modules/pkgs/dwmblocks;
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
    feh --bg-fill $HOME/.config/wallpapers/wallpaper1.png &
    xautolock -time 5 -locker /run/wrappers/bin/slock -corners 0-00 &
  '';
}

