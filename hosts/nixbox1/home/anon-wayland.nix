{ config, pkgs, ... }:

{
  imports = [
    ../../../modules/pkgs/slstatus.nix
    ../../../modules/pkgs/foot.nix
    ../../../modules/pkgs/dwl.nix
    ../../../modules/pkgs/fonts.nix
    ../../../modules/pkgs/swaylock.nix
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
  };

  services.swayidle.enable = true;

  # --- User Packages ---
  home.packages = with pkgs; [
    # CLI & Utilities
    ani-cli
    pavucontrol
    mpv
    fastfetch
    keepassxc
    alsa-utils
    uv
    devenv
    
    # Desktop Applications / GUI
    brave
    librewolf

    wayland-utils
    wmenu
    wl-clipboard
    swaybg
    wlr-randr
    grim
    slurp
    satty
    imv
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
    };
  };
}
