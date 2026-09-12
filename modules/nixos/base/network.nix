{ lib, users, ... }:

{
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  users.users = lib.genAttrs users (_: {
    extraGroups = [ "networkmanager" ];
  });
}
