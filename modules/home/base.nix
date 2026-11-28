{
  pkgs,
  pkgsUnstable,
  config,
  hostName,
  ...
}:

# Shell, editor, and CLI tools shared by graphical and headless hosts.
{
  home.packages = with pkgs; [
    fastfetch
    dysk
    tree
    uv
    devenv

    # The lone unstable package; update its input independently of the system.
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

    bash = {
      enable = true;

      # Absolute repository path and current hostname work from any directory.
      shellAliases.rebuild = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/nixos-dotfiles#${hostName}";
    };
  };
}
