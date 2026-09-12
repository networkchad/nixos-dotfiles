{ config, lib, ... }:

# The machine facts a session must not hardcode: the wallpaper, and which
# connectors exist, at what mode, in what order. hosts/<name>/home.nix declares
# them; this renders the `layout.xrandrArgs` the session runs and links the
# wallpaper.
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
        description = "Primary output.";
      };

      rightOf = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Place right of this output.";
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
      type = types.path;
      example = ../../pics/2077.png;
      description = "Image linked at ~/.config/wallpapers/bg.png and set by feh.";
    };

    vars.outputs = mkOption {
      type = types.attrsOf output;
      default = { };
      description = "Monitor layout, keyed by connector name (eDP-1, HDMI-0, ...).";
    };

    # Derived from vars.outputs; read by modules/home/desktop.nix.
    layout.xrandrArgs = mkOption {
      type = types.str;
      internal = true;
      default = "";
      description = "xrandr arguments for vars.outputs.";
    };
  };

  config =
    let
      inherit (builtins) isNull sort;
      inherit (lib) concatStringsSep mapAttrsToList optionalString;

      # Attribute order is alphabetical and meaningless for a physical layout, so
      # render by the host's `order` (name breaks ties): xrandr resolves
      # --right-of only against an output it has already seen.
      sorted =
        sort
          (a: b: [ a.order a.name ] < [ b.order b.name ])
          (mapAttrsToList (name: o: { inherit name; } // o) config.vars.outputs);

      # --rate only means something next to a mode; --auto takes the preferred one.
      modeArg =
        e:
        "--mode ${e.mode}" + optionalString (!isNull e.rate) " --rate ${toString e.rate}";

      xrandrOutput =
        e:
        "--output ${e.name} "
        + (if isNull e.mode then "--auto" else modeArg e)
        + optionalString e.primary " --primary"
        + optionalString (!isNull e.rightOf) " --right-of ${e.rightOf}";
    in
    {
      # Empty for a machine with only its built-in panel: X already uses the
      # panel's preferred mode.
      layout.xrandrArgs = concatStringsSep " " (map xrandrOutput sorted);

      xdg.configFile."wallpapers/bg.png".source = config.vars.wallpaper;
    };
}
