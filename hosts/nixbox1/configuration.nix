{ config, pkgs, lib, hostName, sessionType, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/utils/bootloader-systemd.nix
    ../../modules/utils/network.nix
    ../../modules/utils/nvidia.nix
    ../../modules/utils/docker.nix
    ../../modules/utils/qemu.nix
    ../../modules/utils/tailscale.nix
    ../../modules/utils/i18n.nix
    ../../modules/utils/keyboard-jp.nix
    ../../modules/utils/pipewire.nix
  ]
  ++ lib.optionals (sessionType == "x") [
    ../../modules/utils/x.nix
    ../../modules/utils/ly.nix
    ../../modules/pkgs/dwm.nix
    ../../modules/pkgs/slock.nix
  ]
  ++ lib.optionals (sessionType == "wayland") [
    ../../modules/utils/wayland-addons.nix
    ../../modules/utils/greetd.nix
    ../../modules/utils/pam.nix
  ];

  networking.hostName = hostName;

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

  # --- Nix Daemon Settings ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  system.stateVersion = "26.05";
}
