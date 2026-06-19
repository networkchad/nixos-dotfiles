{ config, pkgs, ... }:

{
  imports = [
    ../../../modules/pkgs/slstatus.nix
    ../../../modules/pkgs/foot.nix
    ../../../modules/pkgs/dwl.nix
    ../../../modules/pkgs/fonts.nix
  ];

  home.username = "anon";
  home.homeDirectory = "/home/anon";
  home.stateVersion = "26.05";

  # --- XDG Configuration Files ---
  xdg.configFile = {
    "slstatus/scripts" = {
      source = ../../../src/slstatus/scripts;
      recursive = true;
    };
    
    "wallpapers/2077.png".source = ../../../pics/2077.png;

    "dwl/wayland-session" = {
      source = ../../../src/dwl/scripts/start-dwl.sh;
      executable = true;
    };
  };

  # --- User Packages ---
  home.packages = with pkgs; [
    # CLI & Utilities
    ani-cli
    pavucontrol
    mpv
    flameshot
    fastfetch
    keepassxc
    alsa-utils
    uv
    devenv
    
    # Desktop Applications / GUI
    brave
    librewolf

    wmenu
    foot
    wl-clipboard
    swaylock
    swaybg
    wlr-randr
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
        copy = "wl-copy <";
      };
      profileExtra = ''
        if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
          exec dwl -s "$HOME/.config/dwl/wayland-session"
        fi
      '';  
    };
  };
}
