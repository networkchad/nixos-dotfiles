{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # --- Bootloader ---
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # --- Networking & Firewall ---
  networking = {
    hostName = "nixbox";
    networkmanager.enable = true;
    
    # Modern nftables backend with Tailscale permissions
    nftables.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = [ config.services.tailscale.interfaceName "virbr0"];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };

  # --- Hardware & Drivers ---
  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
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
  };

  # --- Localization & Input Methods ---
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

  # --- Virtualization ---
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  systemd.tmpfiles.rules = [
    "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware"
  ];

  # --- Systemd Service Overrides ---
  systemd.services.tailscaled.serviceConfig.Environment = [ 
    "TS_DEBUG_FIREWALL_MODE=nftables" 
  ];

  # --- User Accounts ---
  users.users."anon" = {
    isNormalUser = true;
    description = "anon";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ ];
  };

  # --- System Packages & Environment ---
  nixpkgs.config.allowUnfree = true;

  environment = {
    systemPackages = with pkgs; [
      vim
      wget
      git
      qemu
      docker-compose
      dnsmasq
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
    virt-manager.enable = true;
    slock = {
      enable = true;
      package = pkgs.slock.overrideAttrs (oldAttrs: {
        src = ./config/slock;
      });
    };
  };

  # --- System Services ---
  services = {
    tailscale.enable = true;
    displayManager.ly.enable = true;

    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
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

  # --- Nix Daemon Settings ---
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
  };

  system.stateVersion = "26.05";
}
