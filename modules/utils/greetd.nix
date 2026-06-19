{ config, pkgs, ... }:

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
        # Use tuigreet to launch dwl directly
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd dwl";
        user = "greeter";
      };
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = "simple";
  };
}
