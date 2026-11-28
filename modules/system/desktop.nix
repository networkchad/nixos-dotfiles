{ pkgs, ... }:

# Graphical system profile. Hosts import it explicitly and override the US keyboard
# default only when needed.
{
  imports = [ ./forks.nix ]; # dwm and slock are the ../../src forks

  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;

    # NVIDIA PRIME BusIDs are written only to xorg.conf; disabling this breaks offload.
    exportConfiguration = true;

    # Supplies the ly session entry and dwm binary; ~/.xsession controls startup.
    windowManager.dwm.enable = true;
  };

  services.displayManager = {
    ly = {
      enable = true;

      settings = {
        # Do not persist username/session in cleartext /etc/ly/save.txt.
        save = false;

        # This row runs the same dwm wrapper, so it is not a shell. Use tty2 for rescue.
        shell = false;
      };
    };

    defaultSession = "none+dwm";
  };

  # Keep man pages, but omit HTML/info/NixOS documentation from the desktop closure.
  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-chewing
    ];
  };

  security.rtkit.enable = true;
  services.pipewire.alsa.support32Bit = true; # Steam/Wine/old games

  programs.slock.enable = true;

  services.picom = {
    enable = true;

    # st alpha needs a compositor. GLX/vsync runs on the Intel session GPU under PRIME;
    # unredir-if-possible lets fullscreen applications bypass picom's swap chain.
    backend = "glx";
    vSync = true;
    settings.unredir-if-possible = true;
  };

  # Suspend on lid close on battery or external power, but keep docked laptops running.
  # The session's xss-lock setup locks before sleep; logind does not handle locking.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };
}
