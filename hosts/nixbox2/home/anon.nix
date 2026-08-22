{ ... }:

# Host-specific home deltas only; everything shared lives in
# ../../modules/home/common.nix and the session module.
{
  xdg.configFile."wallpapers/bg.png".source = ../../../pics/nix-wallpaper-dracula.png;
}
