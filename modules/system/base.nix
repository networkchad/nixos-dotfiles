{
  pkgs,
  lib,
  users,
  hostName,
  ...
}:

# The core every host in the host table gets, imported by the flake. Every other
# file in this directory is a service a host picks by importing it: a third
# machine that is a headless box simply does not import ./desktop.nix. Per-host
# facts live in ../../hosts/<name>/, the user half in ../home/base.nix.
{
  networking.hostName = hostName;

  boot.loader = {
    systemd-boot.enable = true;
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

  # Every name in the host table, and only the group that is always right. The
  # modules that need more append their own (networkmanager in ./network.nix,
  # docker in ./docker.nix, libvirtd in ./libvirtd.nix), so nothing here has to
  # know which services a machine runs -- and a host that runs neither asks for
  # a group nobody creates.
  users.users = lib.genAttrs users (_: {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  });

  time.timeZone = "Asia/Taipei";

  i18n.defaultLocale = "en_US.UTF-8"; # no extraLocaleSettings: nothing differs from LANG

  programs.nix-ld.enable = true; # binaries installed outside Nix find their libs

  # The two things worth having on a fresh tty before anything is installed.
  environment.systemPackages = with pkgs; [
    wget
    git
  ];

  # Every host in the table was installed on the release this flake pins; a host
  # carried over from an older one overrides this (single-value option: with
  # `lib.mkForce`, in its own configuration.nix).
  system.stateVersion = "26.05";
}
