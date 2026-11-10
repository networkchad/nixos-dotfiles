{
  pkgs,
  pkgsUnstable,
  lib,
  config,
  hostName,
  ...
}:

# The user half every host gets, imported by the flake: a shell, an editor, the
# tools that work over ssh or on a tty. The session and the apps with windows
# are ./desktop.nix, which a graphical host imports itself. Identity comes
# from the host table in ../../flake.nix; a host carried over from an older
# release states its own stateVersion below.
{
  # Every host in the table was created on the release this flake pins;
  # mkDefault, so an older host overrides it with a plain assignment in its own
  # home.nix.
  home.stateVersion = lib.mkDefault "26.05";

  home.packages = with pkgs; [
    fastfetch
    dysk
    uv
    devenv
    pi-coding-agent

    # The only package in the tree outside the pinned revision: it moves weekly
    # and nixos-26.05 lags it by a major version (1.15.x against 2.2.x), so it
    # comes from nixpkgs-unstable -- `pkgsUnstable` in ../../flake.nix, and
    # `nix flake update nixpkgs-unstable` bumps it without touching the system.
    pkgsUnstable.opencode
  ];

  programs = {
    home-manager.enable = true;
    btop.enable = true;

    vim = {
      enable = true;
      extraConfig = ''
        syntax on
        set number
      '';
    };

    # Enabled here; ./desktop.nix adds the clipboard alias to the same program
    # (and used to add a tty1 `startx` autostart, which ly replaced).
    bash = {
      enable = true;

      # Rebuild the machine you are typing on. `hostName` is the host table's and
      # arrives as a module argument through home-manager's extraSpecialArgs -- the
      # nixosSystem specialArgs stop at the system layer -- so this one line in this
      # one file is right on every host and no host file repeats it. The flake is an
      # absolute path (the repo's documented location, which is also what the
      # /etc/nixos symlink points at), so the alias works from any directory and not
      # only from a checkout the way `--flake .` does.
      shellAliases.rebuild = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/nixos-dotfiles#${hostName}";
    };
  };
}
