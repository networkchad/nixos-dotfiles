{ config, lib, ... }:

# One XKB layout feeding both X11 and Wayland; the host declares which one.
{
  options.vars.keyboard = lib.mkOption {
    type = lib.types.str;
    example = "jp";
    description = "XKB layout name.";
  };

  config = {
    environment.sessionVariables.XKB_DEFAULT_LAYOUT = config.vars.keyboard;
    services.xserver.xkb.layout = config.vars.keyboard;
  };
}
