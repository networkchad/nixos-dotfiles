{ pkgs, ... }:

{
  programs.swaylock = {
    enable = true;
    settings = {
      color = "000000";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      line-color = "ffffff";
      show-failed-attempts = true;
      key-hl-color = "eeeeee";
      inside-input-color = "000000";
      ring-input-color = "eeeeee";
      inside-wrong-color = "f4cccc";
      ring-wrong-color = "f4cccc";
      text-wrong-color = "000000";
    };
  };
}
