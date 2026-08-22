# NixOS Dotfiles

"I use Nix btw"

![System Showcase](pics/demo.png)

## Layout

```
flake.nix            composition root: host table + session selection
hosts/
  common.nix         system config shared by all hosts
  <host>/            per-host deltas only (configuration.nix, hardware, home/)
modules/
  nixos/             system-layer modules (services, hardware, network)
    sessions/        system side of each WM stack (dwm, dwl)
  home/              home-manager modules
    common.nix       home config shared by all hosts and sessions
    packages/        one file per (custom-built) app
    sessions/        home side of each WM stack (dwm, dwl)
src/                 vendored suckless-style sources (dwm, dwl, st, ...)
pics/                wallpapers
```

## Hosts

| host    | session | notes                        |
| ------- | ------- | ---------------------------- |
| nixbox1 | dwm     | nvidia (open), JP keyboard   |
| nixbox2 | dwl     | nvidia (legacy), US keyboard |

Switching a host's session is a one-word change in the `hosts` table in
`flake.nix`.
