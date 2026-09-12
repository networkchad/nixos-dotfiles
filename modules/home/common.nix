{ pkgs, ... }:

# Home config shared by every host and session. Identity (home.username,
# home.homeDirectory) comes from the host table via lib/make-system.nix.
{
  imports = [ ./display.nix ];

  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # Both sessions type Japanese through fcitx5, so CJK fonts are shared.
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

  # Both sessions run slstatus.
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
