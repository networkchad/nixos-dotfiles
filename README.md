# NixOS Dotfiles

"I use Nix btw"

![System Showcase](pics/demo.png)

## Layout

```
flake.nix                 two outputs' worth of logic; no config lives here
lib/make-system.nix       one host table entry -> one nixosSystem
hosts/
  default.nix             THE host table: system, users, session
  common.nix              system config every host shares
  <host>/configuration.nix   host deltas: hardware, GPU, keymap, VM stack
  <host>/home.nix            host facts: wallpaper, monitor layout
modules/
  sessions.nix            session registry (name -> system + home module)
  nixos/                  system layer: base/, desktop/, hardware/, services/, sessions/
  home/                   user layer: common.nix, options.nix, display.nix, packages/, sessions/
overlays/vendored.nix     the local forks in src/ (one place, not five)
src/                      vendored C sources (dwm, dwl, st, slock, slstatus)
patches/                  where each local C change came from (see patches/README.md)
pics/                     wallpapers
```

The flake exports `nixosConfigurations` and nothing else.

## The two rules this repo runs on

**1. Layers never reach across each other.**

| layer | knows about | never mentions |
| --- | --- | --- |
| `hosts/<name>/` | this machine's hardware | WMs, sessions, usernames |
| `modules/*/sessions/` | one WM stack | connector names, hostnames |
| `modules/nixos/base/`, `modules/home/common.nix` | everything shared | specific hosts |

**2. Host facts flow through options, not hardcoding.** `modules/home/options.nix`
declares a `vars` namespace; the host declares it and `modules/home/display.nix`
renders it into whatever the active session needs:

```nix
# hosts/nixbox1/home.nix
vars.wallpaper = ../../pics/2077.png;
vars.outputs = {
  eDP-1     = { primary = true; order = 10; };
  HDMI-1-0  = { mode = "2560x1440"; rate = 144; rightOf = "eDP-1"; order = 20; };
};
```

* under **dwm** that becomes the `xrandr` line in `~/.xsession`;
* under **dwl** it becomes `~/.config/session/display.sh`, which dwl's
  autostart runs (the hardcoded `wlr-randr` call it used to carry is gone).

An empty `vars.outputs` (a laptop with only its built-in panel, like nixbox2)
renders nothing: no `xrandr` line, no script at all — wlroots already uses the
panel's preferred mode, and dwl's autostart skips a missing file.

That is what makes the one-word session switch real: monitor names live with
the machine, so moving a host to the other session keeps its layout instead of
inheriting someone else's.

Usernames work the same way — the host table is the only place `anon` appears;
`modules/nixos/base/users.nix` creates the accounts and `lib/make-system.nix`
sets `home.username` from the same list. Group membership is declared by the
module that needs it (`base/network.nix` adds `networkmanager`,
`services/docker.nix` adds `docker`, `services/qemu.nix` adds `libvirtd`).

## Hosts

| host    | session | notes                           |
| ------- | ------- | ------------------------------- |
| nixbox1 | dwm     | nvidia (open), JP, panel + HDMI |
| nixbox2 | dwl     | nvidia (legacy), US, panel only |

Switching a host's session is a one-word change to `session` in
`hosts/default.nix`. A name that is not in `modules/sessions.nix` fails
evaluation with a list of valid names instead of silently importing nothing.

**Adding a host**

1. `hosts/<name>/hardware-configuration.nix` — from `nixos-generate-config` on the box.
2. `hosts/<name>/configuration.nix` — import it plus the `hardware/` modules it needs, declaring the facts they ask for (`vars.keyboard`, `vars.nvidia`).
3. `hosts/<name>/home.nix` — `vars.wallpaper` and `vars.outputs`.
4. Add the entry to `hosts/default.nix`.

## Vendored forks

`src/` holds hand-patched copies of dwm, dwl, st, slock and slstatus. They are
defined **once**, in `overlays/vendored.nix`, which `lib/make-system.nix`
applies to the package set before any module can say `pkgs.dwl`:

* `patches = [ ]` — upstream's patch list is dropped on purpose; the local
  changes are carried in the source (provenance: `patches/README.md`).
* `version = "<upstream>-local"` — so a fork rebuild is visible in
  `nixos-rebuild` output (`dwm-6.6-local`, `dwl-0.8-local`, ...) instead of
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
