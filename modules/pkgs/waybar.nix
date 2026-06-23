{
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      modules-center = [ "clock" ];
    };
    style = ''
      window#waybar {
        background: #000000;
        color: #ffffff;
      }
    '';
  };
}
