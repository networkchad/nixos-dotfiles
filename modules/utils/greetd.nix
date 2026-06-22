{ pkgs, sessionType, ... }:

let
  sessionCommand =
    if sessionType == "dwm" then
      "--sessions /run/current-system/sw/share/xsessions"
    else if sessionType == "dwl" then
      "--cmd \"slstatus -s | dwl\""
    else
      throw "Unsupported sessionType: ${sessionType}";
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
          ${sessionCommand}
      '';
    };
  };
}
