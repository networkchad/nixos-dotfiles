{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../base.nix
    ../../modules/utils/nvidia-pre-turing.nix
    ../../modules/utils/tailscale.nix
  ];

  networking.hostName = "nixbox2";

  # --- Docker Configuration ---
  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [ docker-compose ];
  users.users.anon.extraGroups = [ "docker" ];

  # --- Time Zone & Localization ---
  time.timeZone = "Asia/Taipei";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
    
    # Language Input Method Engine (IME)
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = false;
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-chewing
        ];
      };
    };
  };

  # --- Keyboard Layout & Environment Variables ---
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  environment.sessionVariables = {
    XMODIFIERS = "@im=fcitx";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
  };
}
