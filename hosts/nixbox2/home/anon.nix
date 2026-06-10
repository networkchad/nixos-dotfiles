{ config, pkgs, ... }:

{
  imports = [
    ../../../modules/pkgs/st.nix
    ../../../modules/pkgs/dwmblocks.nix
  ];

  home.username = "anon";
  home.homeDirectory = "/home/anon";
  home.stateVersion = "26.05";

  # --- XDG Configuration Files ---
  xdg.configFile."dwmblocks/scripts" = {
    source = ../../../src/dwmblocks/scripts;
    recursive = true;
  };
  
  xdg.configFile."wallpapers/wallpaper1.png".source = ../../../pics/wallpaper1.png;

  # --- Services ---
  services.picom.enable = true;

  # --- User Packages ---
  home.packages = with pkgs; [
    # CLI & Utilities
    ani-cli
    pavucontrol
    mpv
    feh
    flameshot
    xclip
    fastfetch
    keepassxc
    uv
    arandr
    alsa-utils
    xautolock
    
    # Desktop Applications / GUI
    dmenu
    brave
    ledger-live-desktop
  ];

  # --- Programs ---
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

  # --- X Session Settings & Startup ---
  xsession.enable = true;
  xsession.initExtra = ''
    fcitx5 -d &
    dwmblocks &
    feh --bg-fill $HOME/.config/wallpapers/wallpaper1.png &
    xautolock -time 5 -locker /run/wrappers/bin/slock -corners 0-00 &
  '';
}

