{ config, pkgs, ... }:

{
  environment.sessionVariables = {
    XKB_DEFAULT_LAYOUT = "jp";
  };

  services.xserver.xkb = {
    layout = "jp";
    variant = "";
  };
}
