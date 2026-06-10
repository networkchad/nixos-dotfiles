{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/utils/nvidia.nix
    ../../modules/utils/docker.nix
    ../../modules/utils/qemu.nix
    ../../modules/utils/tailscale.nix
  ];

  networking.hostName = "nixbox1";

  # --- Bootloader ---
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # --- Networking ---
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # --- User Accounts ---
  # Merged normal settings and group permissions for "anon" here
  users.users."anon" = {
    isNormalUser = true;
    description = "anon";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" ];
  };

  # --- System Packages & Environment ---
  nixpkgs.config.allowUnfree = true;

  environment = {
    systemPackages = with pkgs; [
      wget
      git
    ];
    sessionVariables = {
      XMODIFIERS = "@im=fcitx";
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # --- Programs ---
  programs = {
    nix-ld.enable = true;
    slock = {
      enable = true;
      package = pkgs.slock.overrideAttrs (oldAttrs: {
        src = ../../modules/pkgs/slock;
      });
    };
  };

  # --- System Services ---
  services = {
    displayManager.ly.enable = true;
    xserver = {
      enable = true;
      autoRepeatDelay = 200;
      autoRepeatInterval = 35;
      xkb = {
        layout = "jp";
        variant = "";
      };
      windowManager.dwm = {
        enable = true;
        package = pkgs.dwm.overrideAttrs (oldAttrs: {
          src = ../../modules/pkgs/dwm;
        });
      };
    };
  };

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

  # --- Nix Daemon Settings ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  system.stateVersion = "26.05";
}
