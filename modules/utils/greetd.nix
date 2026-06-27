{ pkgs, sessionType, ... }:

let
  sessions = {
    "dwm" = "${pkgs.bash}/bin/bash -c '${pkgs.xinit}/bin/startx \$HOME/.xsession'";
    "dwl" = "${pkgs.bash}/bin/bash -c 'slstatus -s | dwl'";
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
