{ pkgs, ... }:

{
  imports = [
    ../pkgs/slstatus.nix
    ../pkgs/foot.nix
    ../pkgs/dwl.nix
    ../pkgs/fonts.nix
    ../pkgs/swaylock.nix
  ];

  services.swayidle.enable = true;

  home.packages = with pkgs; [
    wayland-utils
    wmenu
    wl-clipboard
    swaybg
    wlr-randr
    grim
    slurp
    satty
    imv
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
