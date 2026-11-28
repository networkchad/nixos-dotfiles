# NixOS Dotfiles

"I use Nix btw"

![System Showcase](pics/demo.png)

Personal NixOS configuration for two **X11 + dwm** laptops, using **ly**, Home Manager, and the vendored suckless forks in `src/`.

> **Lean by design — contributors and agents:** this is a personal configuration, not a general framework. Prefer native NixOS/Home Manager options, small single-purpose modules, and packages/services that are actually used. Do not add speculative abstractions, duplicate wrappers, convenience packages, or backup/snapshot systems. Keep prose short: operator instructions live here, non-obvious implementation rationale lives beside the code, and neither should repeat the other. Confirm a feature is unused before removing it; the current container, VM, browser, and desktop-tool choices are intentional.

## Layout

```text
flake.nix                     host table and shared NixOS/Home Manager assembly
modules/system/               opt-in system services plus the shared base
modules/home/                 shared CLI and desktop configuration
hosts/<host>/
  configuration.nix           service imports and host-specific settings
  home.nix                    wallpaper, display layout, and per-host Home Manager settings
  hardware-configuration.nix  generated hardware configuration
src/                          dwm, st, slock, and slstatus source trees
patches/                      fork provenance, verification, and rebase guide
pics/                         wallpapers and screenshots
```

The flake imports the shared base modules; each host names its optional service modules. Hardware facts such as PRIME bus IDs and NVIDIA driver generation use native options in the host file. `hostName` and `users` are passed as module arguments rather than repeated inside modules.

## Hosts

| Host | Configuration |
| --- | --- |
| `nixbox1` | Open NVIDIA driver, Japanese keyboard, panel + HDMI, Docker/Kubernetes/libvirt |
| `nixbox2` | Legacy 580 NVIDIA driver, US keyboard, panel + Docker |

To add a host, generate its hardware configuration, provide the other two host files, and add its host-table entry.

## Session

```text
ly (tty1, no autologin)
└─ X + xsession-wrapper
   └─ ~/.xsession: fcitx5, slstatus, xrandr, feh, locking, then dwm
```

The empty `xsession.windowManager.command` and the explicit session lifecycle in `modules/home/desktop.nix` are load-bearing; do not "simplify" them into a second dwm or skip teardown.

Logs:

```sh
journalctl -t xsession          # session programs
journalctl -t xserver-wrapper   # X server
journalctl -u display-manager   # ly; its own log is /var/log/ly.log
```

## Vendored forks

The overlay in `modules/system/forks.nix` builds the four local source trees and is shared with Home Manager through `useGlobalPkgs`. Base commits, local deviations, verification, and the rebase procedure are documented in [`patches/README.md`](patches/README.md).

## Commands

Run from the repository root; replace `nixbox1` with the target host.

```sh
sudo nixos-rebuild switch --flake .#nixbox1   # build and activate
nixos-rebuild build --flake .#nixbox1         # no activation or boot entry
sudo nixos-rebuild boot --flake .#nixbox1     # set next boot without activating
nixos-rebuild dry-activate --flake .#nixbox1  # build and preview without activating
nix flake check -L                            # hosts, custom forks, and linters
nix fmt                                       # format with the locked formatter
nix fmt -- --fail-on-change                   # formatting gate
```

The `rebuild` shell alias switches the current host using the absolute repository path, so it works from any directory. For a failed build add `--show-trace`; for a bad activation use `sudo nixos-rebuild switch --rollback` or the previous boot entry.

### `/etc/nixos` symlink

When `/etc/nixos/flake.nix` exists, `nixos-rebuild` selects `nixosConfigurations.<hostname>`. Link it once per host:

```sh
sudo mv /etc/nixos /etc/nixos.installer-backup
sudo ln -s /home/$USER/nixos-dotfiles /etc/nixos
nixos-rebuild dry-activate   # should select the actual host, not "nixos"
```

Without the link, a command that omits `--flake` can build the installer configuration instead. Git-backed flakes include dirty changes to **tracked** files; add new required files to Git before building.

Nix GC runs weekly with 14-day retention. Manual cleanup: `sudo nix-collect-garbage -d`.

### Updating inputs

`nixpkgs-unstable` supplies only `opencode`; it must stay independent of the stable pin. Home Manager's nixpkgs input follows stable nixpkgs, but its own revision is locked separately.

```sh
nix flake update nixpkgs-unstable   # opencode only
nix flake update nixpkgs            # stable nixpkgs only
nix flake update home-manager       # Home Manager revision
nix flake update                    # all three inputs, only when intended
```

Update inputs separately to isolate regressions. Roll back a bad system activation with `sudo nixos-rebuild switch --rollback`; restore an unwanted lockfile change with Git.

## CI

On pushes to `main` and pull requests, CI runs the formatting gate and `nix flake check`. This evaluates every host, builds the custom forks, and runs ShellCheck and actionlint. Run the network-dependent fork provenance check manually with `./patches/verify.sh`.

## External state

A rebuild does not supply secrets or migrate runtime state:

- **Account password:** none is declared, so a new account is locked. Set it as root before leaving the installer with `nixos-enter --root /mnt -c 'passwd anon'`, or later from a root rescue shell. The locked user cannot log in and elevate with `sudo`.
- **Tailscale:** authenticate once per host with `sudo tailscale up`.
- **Wi-Fi:** NetworkManager stores secrets under `/var/lib/NetworkManager`.
- **libvirt:** state lives under `/var/lib/libvirt`; its ISO pool targets `~/Downloads/iso`. Create the pool directory and grant unprivileged QEMU only the required traversal/read access:

  ```sh
  mkdir -p ~/Downloads/iso
  sudo setfacl -m u:qemu-libvirtd:x "$HOME" "$HOME/Downloads"
  sudo setfacl -R -m u:qemu-libvirtd:rX "$HOME/Downloads/iso"
  sudo find ~/Downloads/iso -type d -exec setfacl -m d:u:qemu-libvirtd:rX {} +
  ```

  Alternatively, remove an unwanted pool with `sudo virsh pool-undefine iso`. Guest disks or NVRAM files outside libvirt-managed directories need equivalent access review.
- **SOPS:** keep the age private key at `~/.config/sops/age/keys.txt` when using `k8s.nix`.

This is an inventory of runtime state, not a backup system.
