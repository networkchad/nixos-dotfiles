{ pkgs, sessionType, ... }:

let
  sessionCommand =
    if sessionType == "dwm" then
      "startx"
    else if sessionType == "dwl" then
      "slstatus -s | dwl"
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
          --cmd "${sessionCommand}"
      '';
    };
  };
}
