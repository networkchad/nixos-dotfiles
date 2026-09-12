{ pkgs, ... }:

# What every machine uses, session aside. Identity (home.username,
# home.homeDirectory) comes from the host table via lib/make-system.nix; the
# desktop lives in ./desktop.nix and per-host facts in hosts/<name>/home.nix.
{
  imports = [ ./display.nix ];

  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # fcitx5 types Japanese here, so CJK fonts are not optional.
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

    pavucontrol
    mpv
    fastfetch
    keepassxc
    alsa-utils
    uv
    devenv
    dysk
    brave
    librewolf
    pi-coding-agent
  ];

  fonts.fontconfig.enable = true;

  # slstatus reads its bar segments from here (src/slstatus/config.def.h).
  xdg.configFile."slstatus/scripts" = {
    source = ../../src/slstatus/scripts;
    recursive = true;
  };

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
