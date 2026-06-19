{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/utils/bootloader-systemd.nix
    ../../modules/utils/network.nix
    ../../modules/utils/ly.nix
    ../../modules/utils/nvidia-pre-turing.nix
    ../../modules/utils/docker.nix
    ../../modules/utils/tailscale.nix
    ../../modules/utils/i18n.nix
    ../../modules/utils/x.nix
    ../../modules/utils/keyboard-us.nix

    ../../modules/pkgs/dwm.nix
    ../../modules/pkgs/slock.nix
  ];


  networking.hostName = "nixbox2";

  # --- User Accounts ---
  users.users."anon" = {
    isNormalUser = true;
    description = "anon";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
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

  # --- Nix Daemon Settings ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  system.stateVersion = "26.05";
}

