# NixOS Dotfiles

"I use Nix btw"

![System Showcase](pics/demo.png)

One desktop on both machines: **X11 + dwm**. There used to be a Wayland session
(dwl) as well; carrying two of every module, one per session, cost more than the
second WM was worth. It is in the git history if it ever comes back.

## Layout

```
flake.nix                 two outputs' worth of logic; no config lives here
lib/make-system.nix       one host table entry -> one nixosSystem
hosts/
  default.nix             THE host table: system, users
  common.nix              system config every host shares
  <host>/configuration.nix   host deltas: hardware, GPU, keymap, VM stack
  <host>/home.nix            host facts: wallpaper, monitor layout
modules/
  nixos/                  system layer
    base/                 boot, nix, users, i18n, network, sound
    desktop.nix           X + dwm + picom + slock
    hardware/             keyboard, nvidia (declared per host)
    services/             docker, tailscale, qemu
  home/                   user layer
    common.nix            apps and programs every host uses
    desktop.nix           the session: xsession, startx, X-only tools
    display.nix           host facts in, xrandr args out
overlays/vendored.nix     the local forks in src/ (one place, not five)
src/                      vendored C sources (dwm, st, slock, slstatus)
patches/                  where each local C change came from (see patches/README.md)
pics/                     wallpapers
```

The flake exports `nixosConfigurations` and nothing else.

## The two rules this repo runs on

**1. Layers never reach across each other.**

| layer | knows about | never mentions |
| --- | --- | --- |
| `hosts/<name>/` | this machine's hardware | the WM, other hosts, usernames |
| `modules/nixos/desktop.nix`, `modules/home/desktop.nix` | one WM stack | connector names, hostnames |
| `modules/nixos/base/`, `modules/home/common.nix` | everything shared | specific hosts |

**2. Host facts flow through options, not hardcoding.** `modules/home/display.nix`
declares a `vars` namespace; the host declares it and the same module renders it
into what the session runs:

```nix
# hosts/nixbox1/home.nix
vars.wallpaper = ../../pics/2077.png;
vars.outputs = {
  eDP-1    = { primary = true; order = 10; };
  HDMI-1-0 = { mode = "2560x1440"; rate = 144; rightOf = "eDP-1"; order = 20; };
};
```

That becomes the `xrandr` line in `~/.xsession` — in `order`, because xrandr
resolves `--right-of` only against an output it has already seen. An empty
`vars.outputs` (a laptop with only its built-in panel, like nixbox2) renders
nothing: X already uses the panel's preferred mode.

Monitor names live with the machine, wallpaper is a link at
`~/.config/wallpapers/bg.png`, and neither is spelled anywhere inside a session.

Usernames work the same way — the host table is the only place `anon` appears;
`modules/nixos/base/users.nix` creates the accounts and `lib/make-system.nix`
sets `home.username` from the same list. Group membership is declared by the
module that needs it (`base/network.nix` adds `networkmanager`,
`services/docker.nix` adds `docker`, `services/qemu.nix` adds `libvirtd`).

## Hosts

| host    | notes                              |
| ------- | ---------------------------------- |
| nixbox1 | nvidia (open), JP, panel + HDMI    |
| nixbox2 | nvidia (legacy 580), US, panel only |

Both are in `hosts/default.nix`, which is the only place the flake looks: a
missing host file or a missing `system`/`users` key fails evaluation instead of
silently importing nothing.

**Adding a host**

1. `hosts/<name>/hardware-configuration.nix` — from `nixos-generate-config` on the box.
2. `hosts/<name>/configuration.nix` — import it plus the `hardware/` modules it needs, declaring the facts they ask for (`vars.keyboard`, `vars.nvidia`).
3. `hosts/<name>/home.nix` — `vars.wallpaper` and `vars.outputs`.
4. Add the entry to `hosts/default.nix`.

## Vendored forks

`src/` holds hand-patched copies of dwm, st, slock and slstatus. They are defined
**once**, in `overlays/vendored.nix`, which `lib/make-system.nix` applies to the
package set before any module can say `pkgs.dwm`:

* `patches = [ ]` — upstream's patch list is dropped on purpose; the local
  changes are carried in the source (provenance: `patches/README.md`).
* `version = "<upstream>-local"` — so a fork rebuild is visible in
  `nixos-rebuild` output (`dwm-6.6-local`, `st-0.9.2-local`, ...) instead of
  being name-identical to upstream.
* `src = lib.cleanSource ...` — editing docs or patch notes next to the source
  cannot invalidate the derivation.

Rebasing a fork onto a new upstream release: copy the new release over
`src/<pkg>`, re-apply the entries in `patches/<pkg>/`, keep the local
`config.def.h`.

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
- Checking the host you are *not* sitting on, without building anything:

  ```sh
  nix eval ".#nixosConfigurations.nixbox2.config.system.build.toplevel.drvPath"
  ```

## Garbage collection

Automatic: `nix.gc` in `modules/nixos/base/nix.nix` runs weekly with 14 day
retention. By hand:

```sh
sudo nix-collect-garbage -d
```

No CI, no linters, no `devShell`, no formatter output — this repo is only what
the two machines need. If you ever want a pre-commit or eval-on-push gate, the
hooks live cleanly in `flake.nix` (`checks`) or `.github/workflows/`.
