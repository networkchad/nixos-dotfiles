{ pkgs, ... }:

{
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  environment.systemPackages = with pkgs; [ sway-audio-idle-inhibit ];

  i18n.inputMethod.fcitx5.waylandFrontend = true;

  # home-manager installs swaylock but does not register its PAM service, and
  # nixpkgs only does so for its own programs.swaylock. Without this swaylock
  # cannot unlock.
  security.pam.services.swaylock = { };
}
