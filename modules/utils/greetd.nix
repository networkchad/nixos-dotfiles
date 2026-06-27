{ pkgs, sessionType, ... }:

let
  sessions = {
    "dwm" = "dwm";
    "dwl"  = "slstatus -s | dwl";
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
