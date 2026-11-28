# Vendored fork provenance

`../src/<pkg>` contains upstream suckless Git code plus these recorded deltas. Verification covers every non-config file; local configuration and `slstatus/scripts/` are reviewed separately.

| Fork | Base | Local delta |
| --- | --- | --- |
| `dwm` | `44dbc68` | `dwm/uselessgap.diff`, `config.def.h` |
| `st` | `688f70a` | `st/alpha.diff`, `st/scrollback.diff`, `st/scrollback-mouse.diff`, `config.def.h` |
| `slock` | `3791a99` | `config.def.h` |
| `slstatus` | `614c275` | `config.def.h`, `scripts/` |

Bases come from `https://git.suckless.org/<pkg>`, not release tarballs. They can therefore be newer than `VERSION` in `config.mk` and nixpkgs' release. The overlay clears inherited nixpkgs patches because those target its release tarball while these trees already contain the recorded hunks.

## Patches and local deviations

- `dwm/uselessgap.diff`: tiled gaps (`gappx`), without border+gap for monocle/single-client layouts. [Upstream patch](https://dwm.suckless.org/patches/uselessgaps/) (v2, cirala).
- `st/alpha.diff`: translucent background; local `alpha` is `0.7`, not the patch's `0.8`. [Upstream patch](https://st.suckless.org/patches/alpha/).
- `st/scrollback.diff`: history buffer and `kscrollup`/`kscrolldown`. [Upstream patch](https://st.suckless.org/patches/scrollback/).
- `st/scrollback-mouse.diff`: changes only `config.def.h`. The local binding uses `ControlMask`, not `ShiftMask`, and scrolls five lines instead of one. [Upstream patch](https://st.suckless.org/patches/scrollbackmouse/).

Do not re-add these upstream-base features as local patches:

- dwm's `buttonpress` status-area adjustment, `getatomprop`/`getwindowtype` 32-bit checks, `_NET_ACTIVE_WINDOW` handling, move-then-fullscreen resize, and `refreshrate`.
- slock's Ctrl-U password clearing.
- slstatus's `lscanf()` and the battery/RAM/volume/Wi-Fi code built around it.

## Verify

From the repository root:

```sh
./patches/verify.sh
```

For all four forks this applies the recorded patches to the recorded base and byte-compares everything except each `config.def.h` and slstatus's top-level `scripts/`. It uses an isolated temporary directory, cleans up on exit, and requires network access plus `git`, `patch`, `tar`, and `diff`.

## Rebase a fork

Run from the repository root. Stage and review the new tree in isolation; this example uses dwm, and `new` can be a commit, tag, or `HEAD`.

```sh
pkg=dwm
base=44dbc68                  # current base for this fork
new=HEAD
work=$(mktemp -d)

git clone -q "https://git.suckless.org/$pkg" "$work/upstream"
git -C "$work/upstream" log --oneline "$base..$new"
mkdir "$work/$pkg"
git -C "$work/upstream" archive "$new" | tar -x -C "$work/$pkg"
for p in "$PWD/patches/$pkg/"*.diff; do
  [ -e "$p" ] || continue    # slock/slstatus have local config only
  patch -d "$work/$pkg" -p1 -i "$p"
done

cp "src/$pkg/config.def.h" "$work/$pkg/config.def.h"
diff -ru "src/$pkg" "$work/$pkg" || true
```

Review and test the staged tree before copying files from `"$work/$pkg"` into `src/$pkg`, including deleting files dropped upstream. Preserve slstatus's local `scripts/`. Copy from the `git archive` tree, not the clone, so no `.git` directory enters `src/`.

Update the table and `verify.sh` base commit, then run **Verify**. Refresh contributed patches when upstream changes their context.
