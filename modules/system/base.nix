{
  pkgs,
  lib,
  users,
  hostName,
  ...
}:

# The core every host gets, imported by the flake. Every other file here is a
# service a host picks by importing it, and per-host facts live in
# ../../hosts/<name>/ -- so a headless box simply does not import ./desktop.nix.
{
  networking.hostName = hostName;

  boot.loader = {
    systemd-boot = {
      enable = true;
      # The installer's 1 GiB ESP, and `null` means no limit at all -- the GC only
      # frees a generation after 14 days, so a fortnight of rebuilds fills /boot at
      # the one moment a rollback would be useful.
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

  # Only the group that is always right. The modules needing more append their own
  # (networkmanager, docker, libvirtd), so nothing here knows what a host runs.
  users.users = lib.genAttrs users (_: {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  });

  time.timeZone = "Asia/Taipei";

  i18n.defaultLocale = "en_US.UTF-8"; # no extraLocaleSettings: nothing differs from LANG

  programs.nix-ld.enable = true; # binaries installed outside Nix find their libs

  # Handy on a fresh tty, before anything is installed.
  environment.systemPackages = with pkgs; [
    wget
    git
  ];

  # Every host was installed on the release this flake pins; mkDefault so an older
  # host overrides it with a plain assignment in its own configuration.nix.
  system.stateVersion = lib.mkDefault "26.05";
}
