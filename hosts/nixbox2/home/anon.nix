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
  
  xdg.configFile."wallpapers/nix-wallpaper-dracula.png".source = ../../../pics/nix-wallpaper-dracula.png;

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
    arandr
    alsa-utils
    xss-lock
    uv
    
    # Desktop Applications / GUI
    dmenu
    brave
    librewolf
  ];

  # --- Programs ---
  programs = {
    home-manager.enable = true;
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
    feh --bg-fill $HOME/.config/wallpapers/nix-wallpaper-dracula.png &
    xset s 300
    xss-lock -- slock &
  '';
}

