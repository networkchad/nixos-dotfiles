{ lib, users, ... }:

# Accounts for every user in the host table. Groups other than wheel are added
# by the module that needs them: network.nix, docker.nix, qemu.nix.
{
  users.users = lib.genAttrs users (name: {
    isNormalUser = true;
    description = name;
    extraGroups = [ "wheel" ];
  });
}
