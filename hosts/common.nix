{
  pkgs,
  lib,
  config,
  users,
  hostName,
  ...
}:

# Shared by every host; per-host deltas live in ./<name>/. ../modules/nvidia.nix
# is the one import here, because it needs facts only a host can give.
{
  imports = [ ../modules/nvidia.nix ];

  networking.hostName = hostName;

  # The local forks of ../src, defined once so no module repeats an
  # overrideAttrs: dwm and slock are used here, st and slstatus in
  # ../modules/home.nix, and an overlay is the only thing both halves see.
  # Their patches are carried in the source (provenance: ../patches/README.md),
  # so upstream's `patches` are dropped -- they would apply to code already
  # modified by hand. The `-local` version suffix keeps a fork rebuild visible
  # in nixos-rebuild output.
  nixpkgs.overlays = [
    (
      final: prev:
      lib.genAttrs [
        "dwm"
        "st"
        "slstatus"
        "slock"
      ]
        (
          name:
          prev.${name}.overrideAttrs (old: {
            version = "${old.version}-local";
            src = lib.cleanSource (../src + /${name});
            patches = [ ];
          })
        )
    )
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nixpkgs.config.allowUnfree = true; # brave and the NVIDIA drivers

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

  # Accounts for every name in the host table, with the groups the always-on
  # features below need. The VM stack adds libvirtd on the host that has it.
  users.users = lib.genAttrs users (name: {
    isNormalUser = true;
    description = name;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
  });

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  time.timeZone = "Asia/Taipei";

  i18n = {
    # No extraLocaleSettings: they only matter when a category differs from LANG.
    defaultLocale = "en_US.UTF-8";

    # Typed through fcitx5 on both machines, so system-wide, not per session.
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-chewing
      ];
    };
  };

  # pipewire (+ pulse/alsa compat) comes from the X server's graphical-desktop
  # defaults; rtkit does not -- pipewire only reads this flag.
  security.rtkit.enable = true;

  # 32-bit ALSA, for Steam/Wine/old games.
  services.pipewire.alsa.support32Bit = true;

  # Desktop, system half: X on tty1, dwm, picom, slock. The user half is
  # ../modules/home.nix.
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;

    # No display manager: login stays on the tty and `startx` starts dwm.
    displayManager.startx.enable = true;

    # The vendored fork, on the system PATH because startx execs it.
    windowManager.dwm = {
      enable = true;
      package = pkgs.dwm;
    };
  };

  services.picom.enable = true;

  programs.slock.enable = true; # pkgs.slock is the vendored fork

  # GPU access for containers is set by nvidia.nix, so this stays valid on a
  # machine without one.
  virtualisation.docker.enable = true;

  services.tailscale.enable = true;

  networking.firewall = {
    trustedInterfaces = [ config.services.tailscale.interfaceName ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  environment.systemPackages = with pkgs; [
    wget
    git
    docker-compose
  ];

  # Lets binaries installed outside Nix find their libraries.
  programs.nix-ld.enable = true;

  system.stateVersion = "26.05";
}
