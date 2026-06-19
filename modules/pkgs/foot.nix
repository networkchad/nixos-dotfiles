{ config, pkgs, ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "monospace:size=11";
        dpi-aware = "yes";
      };
      colors = {
        alpha = "0.9";
      };
    };
  };
}
