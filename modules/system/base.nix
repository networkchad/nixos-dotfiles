{
  pkgs,
  lib,
  users,
  hostName,
  ...
}:

# Shared host baseline; optional services remain explicit host imports.
{
  networking.hostName = hostName;

  boot.loader = {
    systemd-boot = {
      enable = true;
      # Bound ESP usage while retaining enough generations for rollback.
      configurationLimit = 6;
    };
    efi.canTouchEfiVariables = true;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Service modules add their own supplementary groups.
  users.users = lib.genAttrs users (_: {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  });

  time.timeZone = "Asia/Taipei";

  i18n.defaultLocale = "en_US.UTF-8";

  programs.nix-ld.enable = true; # support dynamically linked non-Nix binaries

  environment.systemPackages = with pkgs; [
    wget
    git
  ];
}
