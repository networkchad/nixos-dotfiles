{ pkgs, ... }:

{
  programs.swaylock = {
    enable = true;

    settings = {
      color = "000000";

      inside-color = "000000cc";
      ring-color = "eeeeee";
      text-color = "eeeeee";
      line-color = "00000000";

      inside-ver-color = "000000cc";
      ring-ver-color = "eeeeee";
      text-ver-color = "eeeeee";

      inside-wrong-color = "000000cc";
      ring-wrong-color = "f4cccc";
      text-wrong-color = "f4cccc";

      key-hl-color = "eeeeee";
      bs-hl-color = "f4cccc";

      separator-color = "00000000";

      indicator = true;
      indicator-radius = 120;
      indicator-thickness = 8;

      clock = true;
      screenshots = false;
    };
  };
}
