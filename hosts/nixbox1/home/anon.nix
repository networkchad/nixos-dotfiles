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
  
  xdg.configFile."wallpapers/nix-wallpaper-binary-black.png".source = ../../../pics/nix-wallpaper-binary-black.png;

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
    xrandr --output eDP-1 --auto --primary --output HDMI-1-0 --mode 2560x1440 --rate 144 --right-of eDP-1
    feh --bg-fill $HOME/.config/wallpapers/nix-wallpaper-binary-black.png &
    xautolock -time 5 -locker /run/wrappers/bin/slock -corners 0-00 &
  '';
}
