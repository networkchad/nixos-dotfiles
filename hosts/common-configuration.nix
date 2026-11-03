{
  pkgs,
  lib,
  config,
  users,
  hostName,
  ...
}:

# Shared by every host; per-host deltas -- hardware, keymap, GPU, VMs -- live
# in ./<name>/. The user half of the desktop lives in ./common-home.nix.
{
  networking.hostName = hostName;

  # The local forks of ../src, defined once so no module repeats an
  # overrideAttrs: dwm and slock are used here, st and slstatus in ./common-home.nix,
  # and an overlay is the only thing both halves see. Their patches are carried
  # in the source (provenance: ../patches/README.md), so upstream's `patches`
  # are dropped -- they would apply to code already modified by hand.
  #
  # A fork's version is read out of the tree that is actually compiled,
  # src/<name>/config.mk, and never inherited from nixpkgs: `old.version` would
  # name a source tree this derivation does not contain, and the two drift
  # independently (../src can move ahead of nixpkgs, or lag behind it).
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
          let
            # src/<name>/config.mk carries `VERSION = x.y` for its own build.
            version =
              let
                lines = lib.splitString "\n" (builtins.readFile (../src + /${name}/config.mk));
                line = lib.findFirst (lib.hasPrefix "VERSION") null lines;
                matched = if line == null then null else builtins.match "VERSION = +(.*)" line;
              in
              if matched == null || matched == [ ] then
                builtins.throw "src/${name}/config.mk has no `VERSION = <version>` line"
              else
                lib.trim (lib.head matched);

            # The `-local` suffix keeps a fork rebuild visible in nixos-rebuild
            # output; the warning next to it says which way ../src drifted.
            fork = prev.${name}.overrideAttrs (_: {
              version = "${version}-local";
              src = lib.cleanSource (../src + /${name});
              patches = [ ];
            });
          in
          lib.warnIf (
            prev.${name}.version != version
          ) "fork ../src/${name} is ${version}, nixpkgs packages ${prev.${name}.pname} ${prev.${name}.version}: the vendored tree is what builds"
            fork
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
  # ./common-home.nix.
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

  # Docker needs no GPU; each host that has one enables
  # hardware.nvidia-container-toolkit next to its NVIDIA block.
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
