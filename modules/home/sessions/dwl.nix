{
  config,
  lib,
  pkgs,
  ...
}:

# Home side of the dwl (Wayland) session. Monitors and wallpaper come from the
# host's vars; see modules/home/display.nix.
{
  imports = [
    ../packages/foot.nix
    ../packages/swaylock.nix
  ];

  home.packages = with pkgs; [
    # Vendored forks: overlays/vendored.nix.
    dwl
    slstatus

    wayland-utils
    wmenu
    wl-clipboard
    swaybg
    swayidle
    wlr-randr
    grim
    slurp
    satty
    imv
  ];

  # Installed only when the host pins an output; dwl's autostart skips a missing
  # file, so a single-panel laptop configures nothing.
  xdg.configFile."session/display.sh" = lib.mkIf (config.layout.waylandScript != "") {
    text = config.layout.waylandScript;
    executable = true;
  };

  programs.bash = {
    enable = true;

    shellAliases = {
      copy = "wl-copy <";
    };

    profileExtra = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec bash -c 'slstatus -s | dwl'
      fi
    '';
  };
}
