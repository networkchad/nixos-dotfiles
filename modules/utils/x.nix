{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
  };
}
