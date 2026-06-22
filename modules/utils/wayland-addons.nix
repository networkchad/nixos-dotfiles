{ config, pkgs, ... }:

{
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    sway-audio-idle-inhibit
  ];

  i18n.inputMethod.fcitx5.waylandFrontend = true;
}
