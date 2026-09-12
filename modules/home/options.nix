{ lib, ... }:

# `vars` holds the machine facts a session must not hardcode: the wallpaper and
# which connectors exist, at what mode, in what order. Hosts declare them;
# display.nix renders them for whichever session is active.
let
  inherit (lib) mkOption types;

  output = types.submodule {
    options = {
      mode = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Mode such as 2560x1440; null keeps the preferred mode.";
      };

      rate = mkOption {
        type = types.nullOr types.number;
        default = null;
        description = "Refresh rate in Hz.";
      };

      primary = mkOption {
        type = types.bool;
        default = false;
        description = "Primary output (X11 only).";
      };

      rightOf = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Place right of this output (X11 only).";
      };

      order = mkOption {
        type = types.ints.unsigned;
        default = 0;
        description = ''
          Rendering order, lowest first. xrandr applies outputs sequentially, so
          an output using rightOf must come after the one it names.
        '';
      };
    };
  };
in
{
  options = {
    vars.wallpaper = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Image linked at ~/.config/wallpapers/bg.png.";
    };

    vars.outputs = mkOption {
      type = types.attrsOf output;
      default = { };
      description = "Monitor layout, keyed by connector name (eDP-1, HDMI-A-2, ...).";
    };

    # Derived by display.nix, read by the session modules.
    layout.xrandrArgs = mkOption {
      type = types.str;
      internal = true;
      default = "";
      description = "xrandr arguments rendered from vars.outputs.";
    };

    layout.waylandScript = mkOption {
      type = types.str;
      internal = true;
      default = "";
      description = "wlr-randr script rendered from vars.outputs.";
    };
  };
}
