{ config, pkgs, ... }:

{
  programs.swaylock.enable = true;

  services.swayidle = {
    enable = true;
    
    events = {
      before-sleep = "swaylock -fF";
      lock = "swaylock -fF";
    };

    timeouts = [
      {
        timeout = 300;
        command = "swaylock -fF";
      }
    ];
  };
}
