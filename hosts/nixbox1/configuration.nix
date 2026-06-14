{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/utils/bootloader-systemd.nix
    ../../modules/utils/network.nix
    ../../modules/utils/ly.nix
    ../../modules/utils/nvidia.nix
    ../../modules/utils/docker.nix
    ../../modules/utils/qemu.nix
    ../../modules/utils/tailscale.nix
    ../../modules/utils/i18n.nix

    ../../modules/pkgs/dwm.nix
    ../../modules/pkgs/slock.nix
  ];


  networking.hostName = "nixbox1";

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
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    xkb = {
      layout = "jp";
      variant = "";
    };
  };

  # --- Nix Daemon Settings ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "root" "anon" ];
  };

  system.stateVersion = "26.05";
}
