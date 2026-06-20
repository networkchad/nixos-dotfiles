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
        regular0 = "000000";
        regular1 = "cd0000";
        regular2 = "00ff00";
        regular3 = "cdcd00";
        regular4 = "0000ee";
        regular5 = "cd00cd";
        regular6 = "00cdcd";
        regular7 = "e5e5e5";
      };
    };
  };
}
