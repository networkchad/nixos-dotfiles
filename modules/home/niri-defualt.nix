{ pkgs, ... }:

{
  imports = [
    ../pkgs/fonts.nix
    ../pkgs/swaylock.nix
  ];

  services.swayidle.enable = true;

  xdg.configFile."niri/config.kdl".source = ../../src/niri/config.kdl;

  home.packages = with pkgs; [
    alacritty
    fuzzel
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
  };
}
