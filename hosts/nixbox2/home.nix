_: {
  imports = [ ../../modules/home/desktop.nix ];

  # Install-time compatibility baseline, not the current flake release.
  home.stateVersion = "26.05";

  # Empty xrandrArgs keeps the built-in panel's preferred mode.
  vars.wallpaper = ../../pics/nix-wallpaper-dracula.png;
}
