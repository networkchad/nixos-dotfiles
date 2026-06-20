{ config, pkgs, ... }:

{
  services.wayland-pipewire-idle-inhibit = {
    enable = true;

    systemdTarget = "default.target";

    settings = {
      verbosity = "INFO";
      media_minimum_duration = 10;
      idle_inhibitor = "wayland";

      sink_whitelist = [ ];
    };
  };
}
