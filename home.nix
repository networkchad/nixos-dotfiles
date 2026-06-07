{ config, pkgs, ... }:

{
  home.username = "anon";
  home.homeDirectory = "/home/anon";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    dmenu
    firefox
    ani-cli
    pavucontrol
    mpv
    feh
    flameshot
    xclip
    fastfetch
    keepassxc
    btop
    brave
    uv
    (st.overrideAttrs (oldAttrs: {
      src = ./config/st;
    }))
    (dwmblocks.overrideAttrs (oldAttrs: {
      src = ./config/dwmblocks;
    }))
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      xclip = "xclip -selection clipboard -i";
    };
  };
}
