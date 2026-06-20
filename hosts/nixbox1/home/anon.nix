{ config, pkgs, lib, sessionType, ... }:

{
  imports =
    lib.optionals (sessionType == "x") [
      ../../../modules/home/x-default.nix
    ]
    ++ lib.optionals (sessionType == "wayland") [
      ../../../modules/home/wayland-default.nix
    ];

  home.username = "anon";
  home.homeDirectory = "/home/anon";
  home.stateVersion = "26.05";

  xdg.configFile = {
    "slstatus/scripts" = {
      source = ../../../src/slstatus/scripts;
      recursive = true;
    };

    "wallpapers/bg.png".source = ../../../pics/2077.png;
  };

  home.packages = with pkgs; [
    ani-cli
    pavucontrol
    mpv
    fastfetch
    keepassxc
    alsa-utils
    uv
    devenv

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

  xsession.initExtra = lib.mkAfter ''
    xrandr --output eDP-1 --auto --primary --output HDMI-1-0 --mode 2560x1440 --rate 144 --right-of eDP-1 &
  '';
}
