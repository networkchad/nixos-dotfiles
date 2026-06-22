{ pkgs, sessionType, ... }:

let
  sessionCommand =
    if sessionType == "dwm" then
      "--cmd ${pkgs.xorg.xinit}/bin/startx dwm"
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
