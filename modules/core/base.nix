{ config, pkgs, ... }:

{
  # --- Bootloader ---
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # --- Networking (Minimal Base) ---
  networking.networkmanager.enable = true;

  # --- User Accounts ---
  users.users."anon" = {
    isNormalUser = true;
    description = "anon";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # --- System Packages & Environment ---
  nixpkgs.config.allowUnfree = true;

  environment = {
    systemPackages = with pkgs; [
      vim
      wget
      git
    ];
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
        src = ../../config/slock;
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
      windowManager.dwm = {
        enable = true;
        package = pkgs.dwm.overrideAttrs (oldAttrs: {
          src = ../../config/dwm;
        });
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
