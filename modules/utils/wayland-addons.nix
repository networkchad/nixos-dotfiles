{ config, pkgs, ... }:

{
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; 
    IMMODULE = "fcitx";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  i18n.inputMethod.fcitx5.waylandFrontend = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };
}
