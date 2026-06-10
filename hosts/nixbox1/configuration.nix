{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/utils/nvidia.nix
    ../../modules/utils/docker.nix
    ../../modules/utils/qemu.nix
    ../../modules/utils/tailscale.nix
    ../../modules/utils/i18n.nix
    
    ../../modules/pkgs/dwm.nix
    ../../modules/pkgs/slock.nix
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
  };

  # --- Programs ---
  programs.nix-ld.enable = true;

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
    };
  };

  # --- Nix Daemon Settings ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  system.stateVersion = "26.05";
}
