{ config, pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.dwl.overrideAttrs (oldAttrs: {
      src = ../../src/dwl; 
      buildInputs = (oldAttrs.buildInputs or []) ++ [
        pkgs.fcft
        pkgs.libdrm
      ];
    }))
  ];

  services.displayManager.sessionPackages = [
    (pkgs.writeTextFile {
      name = "dwl-wayland-session";
      destination = "/share/wayland-sessions/dwl.desktop";
      text = ''
        [Desktop Entry]
        Name=dwl
        Comment=Dynamic Window Manager for Wayland
        Exec=dwl
        Type=Application
      '';
      passthru.providedSessions = [ "dwl" ];
    })
  ];

  services.displayManager.defaultSession = "dwl";
}
