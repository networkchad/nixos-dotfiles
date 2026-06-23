{
  programs.waybar = {
    enable = true;

    settings.mainBar = {
      modules-left = [ ];

      modules-center = [
        "custom/internet"
        "custom/vpn"
        "custom/volume"
        "cpu"
        "memory"
        "battery"
        "clock"
      ];

      modules-right = [ ];

      "custom/internet" = {
        exec = "printf 'Net:%s' \"$(${HOME}/.config/slstatus/scripts/internet.sh)\"";
        interval = 5;
      };

      "custom/vpn" = {
        exec = "printf 'VPN:%s' \"$(${HOME}/.config/slstatus/scripts/vpn.sh)\"";
        interval = 5;
      };

      "custom/volume" = {
        exec = "printf 'Vol:%s' \"$(${HOME}/.config/slstatus/scripts/volume.sh)\"";
        interval = 1;
      };

      cpu = {
        format = "CPU:{usage}%";
      };

      memory = {
        format = "RAM:{}%";
      };

      battery = {
        format = "Bat:{capacity}%";
      };

      clock = {
        format = "{:%Y-%m-%d %H:%M}";
      };
    };

    style = ''
      window#waybar {
        background: #000;
        color: #fff;
      }

      * {
        border: none;
        border-radius: 0;
        min-height: 0;
        padding: 0 3px;
      }
    '';
  };
}
