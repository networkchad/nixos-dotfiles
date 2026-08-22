{ pkgs, hostName, ... }:

{
  imports = [
    ../modules/nixos/bootloader.nix
    ../modules/nixos/docker.nix
    ../modules/nixos/i18n.nix
    ../modules/nixos/networkmanager.nix
    ../modules/nixos/pipewire.nix
    ../modules/nixos/tailscale.nix
  ];

  networking.hostName = hostName;

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
