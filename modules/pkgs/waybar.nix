{
  programs.waybar = {
    enable = true;

    settings.mainBar = {
      modules-left = [ ];

      modules-center = [
        "cpu"
        "memory"
        "custom/vpn"
        "custom/internet"
        "custom/volume"
        "battery"
        "clock"
      ];

      modules-right = [ ];

      cpu = {
        format = "CPU:{usage}%";
      };

      memory = {
        format = "RAM:{}%";
      };

      battery = {
        format = "B:{capacity}%";
      };

      clock = {
        format = "{:%Y-%m-%d %H:%M}";
      };

      "custom/internet" = {
        exec = "bash -c '~/.config/slstatus/scripts/internet.sh'";
        interval = 5;
        format = "Net:{}";
      };

      "custom/vpn" = {
        exec = "bash -c '~/.config/slstatus/scripts/vpn.sh'";
        interval = 5;
        format = "VPN:{}";
      };

      "custom/volume" = {
        exec = "bash -c '~/.config/slstatus/scripts/volume.sh'";
        interval = 1;
        format = "Vol:{}";
      };
    };

    style = ''
      window#waybar {
        background: #000000;
        color: #ffffff;
      }

      * {
        border: none;
        border-radius: 0;
        min-height: 0;
        padding: 0 4px;
      }
    '';
  };
}
