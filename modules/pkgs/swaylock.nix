{ pkgs, ... }:

{
  programs.swaylock = {
    enable = true;
    settings = {
      color = "000000";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      show-failed-attempts = true;
      key-hl-color = "ffffff";
      inside-wrong-color = "f4cccc";
      ring-wrong-color = "f4cccc";
      text-wrong-color = "000000";
      line-wrong-color = "f4cccc";
    };
  };
}
