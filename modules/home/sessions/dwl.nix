{ pkgs, ... }:

{
  imports = [
    ../packages/dwl.nix
    ../packages/foot.nix
    ../packages/slstatus.nix
    ../packages/swaylock.nix
  ];

  home.packages = with pkgs; [
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

  programs.yazi.settings.opener.image_viewer = [
    {
      run = "${pkgs.imv}/bin/imv -n \"$1\" .";
      desc = "View Image Directory";
    }
  ];

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
