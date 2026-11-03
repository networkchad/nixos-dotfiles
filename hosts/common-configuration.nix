{
  pkgs,
  lib,
  config,
  users,
  hostName,
  ...
}:

# Every host; per-host deltas live in ./<name>/, the user half in ./common-home.nix.
{
  networking.hostName = hostName;

  # The ../src forks, defined once where both halves can see them (dwm and slock
  # here, st and slstatus in ./common-home.nix). Upstream's `patches` are dropped:
  # the local edits are already in the tree (../patches/README.md). `version` is
  # read from src/<name>/config.mk because `old.version` would name a tree this
  # derivation does not build, and `-local` keeps a fork rebuild visible in
  # nixos-rebuild output.
  nixpkgs.overlays = [
    (
      final: prev:
      lib.genAttrs
        [
          "dwm"
          "st"
          "slstatus"
          "slock"
        ]
        (
          name:
          let
            lines = lib.splitString "\n" (builtins.readFile (../src + /${name}/config.mk));
            line =
              lib.findFirst (lib.hasPrefix "VERSION")
                (throw "src/${name}/config.mk has no `VERSION = <version>` line")
                lines;
          in
          prev.${name}.overrideAttrs (_: {
            version = "${lib.trim (builtins.head (builtins.match "VERSION = +(.*)" line))}-local";
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

  # Every name in the host table; a host adds a group when it enables something
  # that needs one (libvirtd on nixbox1).
  users.users = lib.genAttrs users (name: {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
  });

  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Taipei";

  i18n = {
    defaultLocale = "en_US.UTF-8"; # no extraLocaleSettings: nothing differs from LANG

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

  # pipewire and its compat layers come from the X server's defaults; rtkit's
  # realtime flag is read by pipewire but not set by them.
  security.rtkit.enable = true;
  services.pipewire.alsa.support32Bit = true; # Steam/Wine/old games

  # X on tty1, dwm, picom, slock. No display manager: login stays on the tty.
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    displayManager.startx.enable = true;
  };

  services.picom.enable = true;
  programs.slock.enable = true;

  virtualisation.docker.enable = true;
  services.tailscale.enable = true;

  # openFirewall (off by default) opens tailscale's UDP port. Trusting the
  # interface instead of per-port rules lets peers reach services here.
  services.tailscale.openFirewall = true;
  networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];

  # dwm is on the PATH because home-manager's ~/.xsession runs it. Not
  # services.xserver.windowManager.dwm: that only registers a display-manager
  # session, which the startx pseudo-DM never reads.
  environment.systemPackages = with pkgs; [
    wget
    git
    docker-compose
    dwm
  ];

  programs.nix-ld.enable = true; # binaries installed outside Nix find their libs

  system.stateVersion = "26.05";
}
