{ config, pkgs, ... }:

{
  environment.sessionVariables = {
    XKB_DEFAULT_LAYOUT = "us";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}
