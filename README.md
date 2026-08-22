# NixOS Dotfiles

"I use Nix btw"

![System Showcase](pics/demo.png)

## Commands

Run from this repo; swap `nixbox1` for `nixbox2`.

```sh
nixos-rebuild switch --flake .#nixbox1       # build + activate
nixos-rebuild build  --flake .#nixbox1       # build only, change nothing
nixos-rebuild switch --flake .#nixbox1 next  # + set as default boot entry
nixos-rebuild reboot --flake .#nixbox1 next  # switch + reboot
nixos-rebuild dry-activate --flake .#nixbox1 # preview changes, touch nothing
```

- Build fails → add `--show-trace`.
- Bad switch → `sudo nixos-rebuild --rollback` (or pick the previous
  systemd-boot entry at the bootloader).

## Garbage collection

```sh
sudo nix-collect-garbage -d   # drop dead generations (system + user profiles)
```

To automate: set `nix.gc.automatic = true` (plus
`nix.gc.options = "--delete-older-than 14d"`) in `hosts/common.nix`.

## Layout

```
flake.nix            composition root: host table + session selection
hosts/               common.nix (shared) + per-host deltas only
modules/nixos/       system layer; sessions/ = system side of each WM
modules/home/        home layer; packages/ = one file per app,
                     sessions/ = home side of each WM
src/                 vendored C sources (dwm, dwl, st, slock, slstatus)
pics/                wallpapers
```

## Hosts

| host    | session | notes                        |
| ------- | ------- | ---------------------------- |
| nixbox1 | dwm     | nvidia (open), JP keyboard   |
| nixbox2 | dwl     | nvidia (legacy), US keyboard |

Switching a host's session is a one-word change in the `hosts` table in
`flake.nix`.
