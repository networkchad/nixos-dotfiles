{ config, pkgs, lib, ... }:

{
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Fix #1: Updated pkgs.greetd.tuigreet -> pkgs.tuigreet
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd dwl";
        user = "greeter";
      };
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = lib.mkForce "simple";
  };
}
