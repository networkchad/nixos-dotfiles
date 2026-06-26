{ ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "monospace:size=12";
        dpi-aware = "yes";
      };
      colors-dark = {
        alpha = "0.6";
        background = "111111";
        foreground = "cccccc";
      };
    };
  };
}
