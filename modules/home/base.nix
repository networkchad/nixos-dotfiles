{
  pkgs,
  pkgsUnstable,
  lib,
  config,
  hostName,
  ...
}:

# The user half every host gets, imported by the flake: a shell, an editor, the
# tools that work over ssh or on a tty. The session and the apps with windows are
# ./desktop.nix, which a graphical host imports itself. Identity comes from the host
# table in ../../flake.nix.
{
  # Every host was created on the release this flake pins; mkDefault, so an older
  # host overrides it with a plain assignment in its own home.nix.
  home.stateVersion = lib.mkDefault "26.05";

  home.packages = with pkgs; [
    fastfetch
    dysk
    uv
    devenv

    # The one package outside the pinned revision: it moves weekly and nixos-26.05
    # lags it by a major version, so `nix flake update nixpkgs-unstable` bumps it
    # without touching the system.
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

    # Enabled here; ./desktop.nix adds the clipboard alias to the same program.
    bash = {
      enable = true;

      # Rebuild the machine you are typing on. `hostName` is the host table's and
      # arrives through extraSpecialArgs, so this one line is right on every host and
      # no host file repeats it. The flake is an absolute path (the repo's documented
      # location, which /etc/nixos points at), so unlike `--flake .` it works from any
      # directory.
      shellAliases.rebuild = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/nixos-dotfiles#${hostName}";
    };
  };
}
