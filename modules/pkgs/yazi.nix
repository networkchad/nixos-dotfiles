{ pkgs, sessionType, ... }:

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true; 
    enableZshIntegration = true;  

    settings = {
      opener = {
        image_viewer = [
          {
            run = let
              viewers = {
                "dwm" = "${pkgs.feh}/bin/feh --start-at \"$1\" .";
                "dwl" = "${pkgs.imv}/bin/imv -n \"$1\" .";
              };
            in viewers.${sessionType};
            desc = "View Image Directory";
          }
        ];

        media_player = [
          {
            run = "${pkgs.mpv}/bin/mpv --force-window=yes \"$@\"";
            desc = "Play Media (Forced Window)";
          }
        ];

        generic_browser = [
          {
            run = "librewolf --private-window \"$@\"";
            desc = "Open with Default Browser/Viewer";
          }
        ];
      };

      open = {
        rules = [
          { mime = "image/*"; use = "image_viewer"; orphan = true; }
          { mime = "video/*"; use = "media_player"; orphan = true; }
          { mime = "audio/*"; use = "media_player"; orphan = true; }
          { mime = "text/html"; use = "generic_browser"; orphan = true; }
          { mime = "application/pdf"; use = "generic_browser"; orphan = true; }
        ];
      };
    };
  };
}
