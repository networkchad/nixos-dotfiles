{ pkgs, config, sessionType, ... }:

let
  sessions = {
    "dwl"  = "slstatus -s | dwl";
    "niri" = "${config.programs.niri.package}/bin/niri-session";
    "dwm"  = "${pkgs.xorg.xinit}/bin/startx ${config.services.xserver.windowManager.dwm.package}/bin/dwm";
  };

  sessionCommand = sessions.${sessionType} or (throw "Unsupported sessionType: ${sessionType}");
in
{
  services.greetd = {
    enable = true;

    settings.default_session = {
      user = "greeter";

      command = ''
        ${pkgs.tuigreet}/bin/tuigreet \
          --time \
          --remember \
          --asterisks \
          --cmd "${sessionCommand}"
      '';
    };
  };
}
