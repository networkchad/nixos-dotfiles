{ pkgs, ... }:

# Home config shared by every host and session.
{
  home.username = "anon";
  home.homeDirectory = "/home/anon";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # Fonts: both sessions type Japanese through fcitx5, so CJK coverage
    # is a shared requirement, not a session one.
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

    pavucontrol
    mpv
    fastfetch
    keepassxc
    alsa-utils
    uv
    devenv
    dysk
    brave
    librewolf
    pi-coding-agent
  ];

  fonts.fontconfig.enable = true;

  xdg.configFile = {
    # Both sessions run slstatus.
    "slstatus/scripts" = {
      source = ../../src/slstatus/scripts;
      recursive = true;
    };
  };

  programs = {
    home-manager.enable = true;
    btop.enable = true;

    vim = {
      enable = true;
      extraConfig = ''
        syntax on
        set number
      '';
    };

    yazi = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;

      settings = {
        # opener.image_viewer is provided by the session module
        # (feh under dwm, imv under dwl).
        opener = {
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
  };
}
