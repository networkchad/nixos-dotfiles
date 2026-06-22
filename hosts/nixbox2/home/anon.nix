{ config, pkgs, lib, sessionType, ... }:

{
  imports =
    lib.optionals (sessionType == "dwm") [
      ../../../modules/home/dwm-default.nix
    ]
    ++ lib.optionals (sessionType == "dwl") [
      ../../../modules/home/dwl-default.nix
    ];

  home.username = "anon";
  home.homeDirectory = "/home/anon";
  home.stateVersion = "26.05";

  xdg.configFile = {
    "slstatus/scripts" = {
      source = ../../../src/slstatus/scripts;
      recursive = true;
    };

    "wallpapers/bg.png".source = ../../../pics/nix-wallpaper-dracula.png;
  };

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
  ];

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
  };
}
