{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixbox";

  networking.networkmanager.enable = true;

  # nvidia
  hardware.graphics = {
    enable = true;
  };
  
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
  
    powerManagement.enable = true;
    powerManagement.finegrained = true;
  
    open = true;
  
    nvidiaSettings = true;
    
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
  
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  
  # Set your time zone.
  time.timeZone = "Asia/Taipei";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  i18n.inputMethod = {
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

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  systemd.tmpfiles.rules = [ "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware" ];

  users.users."anon" = {
    isNormalUser = true;
    description = "anon";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    packages = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
     vim
     wget
     git
     qemu
     docker-compose
     dnsmasq
  ];

  environment.sessionVariables = {
      XMODIFIERS = "@im=fcitx";
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
    };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  programs = {
    slock = {
      enable = true;
      package = (pkgs.slock.overrideAttrs (oldAttrs: {
        src = ./config/slock;
      }));
    };
    nix-ld = {
      enable = true;
    };
    virt-manager = {
      enable = true;
    };
  };

  services = {

    displayManager = {
      ly.enable = true;
    };

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
          src = ./config/dwm;
        });
      };
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  system.stateVersion = "26.05";

}
