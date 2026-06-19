{ config, pkgs, ... }:

{
  programs.swaylock.enable = true;

  services.swayidle = {
    enable = true;
    
    events = [
      {
        event = "before-sleep";
        command = "swaylock -fF";
      }
      {
        event = "lock";
        command = "swaylock -fF";
      }
    ];

    timeouts = [
      {
        timeout = 300;
        command = "swaylock -fF";
      }
      {
        timeout = 600;
        command = "wlr-randr --output --off"; 
        resumeCommand = "wlr-randr --output --on";
      }
    ];
  };
}
