{ config, pkgs, ... }:

{
  security.pam.services.swaylock = {};

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
