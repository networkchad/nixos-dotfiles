{ config, lib, ... }:

# The host declares its layout; the X server is the only thing that needs it.
{
  options.vars.keyboard = lib.mkOption {
    type = lib.types.str;
    example = "jp";
    description = "XKB layout name.";
  };

  config.services.xserver.xkb.layout = config.vars.keyboard;
}
