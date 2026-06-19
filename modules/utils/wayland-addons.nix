{ config, pkgs, ... }:

{
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; 
  };

  i18n.inputMethod.fcitx5.waylandFrontend

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };
}
