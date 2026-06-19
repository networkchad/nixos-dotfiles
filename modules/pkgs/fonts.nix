{ pkgs, ... }:

{
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];
  fonts.fontconfig.enable = true;
}
