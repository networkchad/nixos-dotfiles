{
  config,
  lib,
  pkgs,
  ...
}:

# Renders the host's vars into what a session consumes: the wallpaper symlink,
# layout.xrandrArgs (used by dwm) and layout.waylandScript (used by dwl).
{
  imports = [ ./options.nix ];

  config =
    let
      inherit (builtins) filter isNull sort;
      inherit (lib) concatStringsSep mapAttrsToList optionalString;

      sorted =
        # Attribute order is alphabetical and meaningless for a physical layout,
        # so render by the host's `order` (name breaks ties): xrandr resolves
        # --right-of only against an output it has already seen.
        sort (
          a: b:
          [
            a.order
            a.name
          ] < [
            b.order
            b.name
          ]
        ) (mapAttrsToList (name: o: { inherit name; } // o) config.vars.outputs);

      withRate = e: !isNull e.rate;
      hz = e: toString e.rate;

      xrandrOutput =
        e:
        "--output ${e.name} "
        + (
          if isNull e.mode then
            "--auto"
          else
            "--mode ${e.mode}${optionalString (withRate e) " --rate ${hz e}"}"
        )
        + optionalString e.primary " --primary"
        + optionalString (!isNull e.rightOf) " --right-of ${e.rightOf}";

      # wlr-randr has no --auto equivalent, so outputs without a mode are skipped.
      modeOutputs = filter (e: !isNull e.mode) sorted;
      wlrOutput =
        e: ''wlr-randr --output ${e.name} --mode "${e.mode}${optionalString (withRate e) "@${hz e}Hz"}"'';
    in
    {
      layout.xrandrArgs = concatStringsSep " " (map xrandrOutput sorted);

      # Empty means "nothing to pin", e.g. a laptop with one panel.
      layout.waylandScript = lib.mkIf (modeOutputs != [ ]) ''
        #!${pkgs.bash}/bin/sh
        # Generated from vars.outputs by modules/home/display.nix; run by dwl's
        # autostart (src/dwl/config.def.h).
        command -v wlr-randr >/dev/null 2>&1 || exit 0
        ${concatStringsSep "\n" (map wlrOutput modeOutputs)}
      '';

      xdg.configFile."wallpapers/bg.png" = lib.mkIf (!isNull config.vars.wallpaper) {
        source = config.vars.wallpaper;
      };
    };
}
