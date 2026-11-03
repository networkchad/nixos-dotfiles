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

  # All four ../src forks, defined here because this is the one module both
  # halves can see: dwm and slock come from the system side, st and slstatus are
  # used by the session in ./common-home.nix. Upstream's `patches` are dropped:
  # the hunks are already in the tree, and upstream's list applies to the release
  # tarball these trees were forked from (../patches/README.md pins each base
  # commit and lists what is actually local). `version` is read from
  # src/<name>/config.mk because `old.version` would name a tree this derivation
  # does not build, and `-local` keeps a fork rebuild visible in nixos-rebuild
  # output.
  nixpkgs.overlays = [
    (
      _final: prev:
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
            # Exactly what the Makefile reads: the sources, the two config files
            # it builds against, and the man page (+ st's terminfo) it installs.
            # LICENSE, README, FAQ and src/slstatus/scripts stay in the repo but
            # out of the derivation, so editing one cannot rebuild a fork.
            src = lib.cleanSourceWith {
              src = ../src + /${name};
              filter =
                path: type:
                type == "directory"
                || lib.any (suffix: lib.hasSuffix suffix path) [
                  ".c"
                  ".h"
                  ".1"
                ]
                || lib.elem (baseNameOf path) [
                  "Makefile"
                  "config.mk"
                  "config.def.h"
                  "st.info"
                ];
            };
            patches = [ ];
          })
        )
    )
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # The unfree set is exactly the NVIDIA stack -- a prefix, because the driver
  # arrives under several names (nixbox1's closure alone carries nvidia-x11,
  # nvidia-open, nvidia-settings, nvidia-x11-bin, nvidia-container-toolkit,
  # nvidia-vaapi-driver) and which of them exist changes between nixpkgs
  # releases. Checked both ways: replace the predicate with `_: false` and
  # evaluating nixbox1 dies on "Refusing to evaluate package 'nvidia-x11-…'
  # because it has an unfree license"; with only this prefix, both systems
  # evaluate, which also proves nothing else needs the grant. brave is not in it
  # -- MPL-2.0, `meta.unfree = false` -- despite what this line used to comment.
  # `useGlobalPkgs` shares the config with home-manager.
  nixpkgs.config.allowUnfreePredicate = pkg: lib.hasPrefix "nvidia" (lib.getName pkg);

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
  users.users = lib.genAttrs users (_: {
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

  # Both machines are laptops. This pins the behavior they already have rather
  # than fixing a bug: NixOS sets none of these (verified: the generated
  # /etc/systemd/logind.conf carries only KillUserProcesses, and logind reports
  # suspend / "" / ignore through busctl), and upstream has moved these defaults
  # before. Empty HandleLidSwitchExternalPower means "not used", so on AC the
  # HandleLidSwitch action applies anyway -- writing "suspend" keeps that
  # behavior and says it out loud. Closed lid on battery suspends; closed lid on
  # the dock (a second output counts as docked) keeps running on HDMI.
  #
  # Locking on the way into suspend is the session's job, not logind's --
  # ./common-home.nix passes the sleep lock to slock through xss-lock.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

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
