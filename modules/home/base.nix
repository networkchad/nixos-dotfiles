{ pkgs, ... }:

# The user half every host gets, imported by the flake: a shell, an editor, the
# tools that work over ssh or on a tty. The session and the apps with windows
# are ./desktop.nix, which a graphical host imports itself. Identity comes
# from the host table in ../../flake.nix; a host carried over from an older
# release overrides it with `lib.mkForce`.
{
  # Every host in the table was created on the release this flake pins.
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    fastfetch
    dysk
    uv
    devenv
    pi-coding-agent
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

    # Enabled here; ./desktop.nix adds the tty1 autostart and the
    # clipboard alias to the same program.
    bash.enable = true;
  };
}
