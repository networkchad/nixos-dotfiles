{ config, pkgs, ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "monospace:size=11";
        dpi-aware = "yes";
      };
      colors-dark = {
        alpha = "0.4";
        background = "111111";
        foreground = "cccccc";
      };
    };
  };
}
