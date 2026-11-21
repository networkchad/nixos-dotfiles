# Vendored fork provenance

Every file under `../src/<pkg>` is upstream suckless code except the files listed
here. The claims are mechanical, not from memory -- [Verify](#verify) regenerates
them.

| fork       | upstream base                                     | local delta                                                     |
| ---------- | ------------------------------------------------- | --------------------------------------------------------------- |
| `dwm`      | `44dbc68` (2026-03-13) `buttonpress: fix status…` | `dwm/uselessgap.diff`, `config.def.h`                             |
| `st`       | `688f70a` (2026-01-14) `st: guard tsetdirt()…`     | `st/alpha.diff`, `st/scrollback.diff`, `st/scrollback-mouse.diff`, `config.def.h` |
| `slock`    | `3791a99` (2025-08-16) `add a comment for the ctrl-u clear field combo` | `config.def.h` only                    |
| `slstatus` | `614c275` (2026-02-12) `license: bump copyright year` | `config.def.h` and `scripts/` (this directory is ours)       |

Bases are upstream git (`https://git.suckless.org/<pkg>`), not release tarballs, so
a base is *newer* than the `VERSION` in `src/<pkg>/config.mk` and than what nixpkgs
packages (dwm: base 6.8+, config.mk 6.8, nixpkgs 6.6). That is why the overlay in
`../modules/system/forks.nix` sets `patches = [ ]` -- the hunks below are already in
`../src`, and upstream's own list targets the tarball.

## What each patch does

* `dwm/uselessgap.diff` -- real gaps between tiled windows (`gappx`,
  `config.def.h:5`), removing border+gap for monocle/single client.
  <https://dwm.suckless.org/patches/uselessgaps/> (v2, by cirala).
* `st/alpha.diff` -- translucent background (`alpha`, `config.def.h:97`), locally
  `0.7` where the upstream patch ships `0.8`.
  <https://st.suckless.org/patches/alpha/>
* `st/scrollback.diff` -- history buffer + `kscrollup`/`kscrolldown`.
  <https://st.suckless.org/patches/scrollback/>
* `st/scrollback-mouse.diff` -- **`config.def.h` only**, so a config line, not code.
  The local line deviates on purpose: `config.def.h:182` binds `ControlMask` (not the
  patch's `ShiftMask`) and steps 5 lines instead of 1.
  <https://st.suckless.org/patches/scrollbackmouse/>

## Things that look local but are not

Do not "re-add" these as patches; they are upstream code carried by the base.

* `dwm/dwm.c:443` `+ lrpad - 2` in `buttonpress` -- the status area's click target,
  which is the base commit's own subject line.
* `dwm/dwm.c` `getatomprop`/`getwindowtype` `format == 32` checks, `setfocus` always
  publishing `_NET_ACTIVE_WINDOW`, `movemouse`-then-fullscreen resize.
* `dwm/dwm.c` `refreshrate` (`config.def.h:39`) -- throttles move/resize.
* `slock/slock.c` ctrl-U clearing the password.
* `slstatus/util.c` `lscanf()`, and the `battery.c`/`ram.c`/`volume.c`/`wifi.c`
  rewrites around it.

## Verify

```sh
R=$PWD; cd $(mktemp -d)
for p in dwm st slock slstatus; do git clone -q https://git.suckless.org/$p; done

# 1. every file the fork does NOT patch is byte-identical to the base commit
git -C slstatus archive 614c275 | tar x -C /tmp/base-slstatus
diff -r /tmp/base-slstatus $R/src/slstatus -x config.def.h -x scripts   # expect: no output

# 2. every patched file equals base + the patch, byte-for-byte
mkdir /tmp/p && git -C dwm archive 44dbc68 | tar x -C /tmp/p
patch -s -d /tmp/p -p1 -i $R/patches/dwm/uselessgap.diff
diff /tmp/p/dwm.c $R/src/dwm/dwm.c                                      # expect: no output
```

## Rebasing a fork onto newer upstream

```sh
cd $(mktemp -d) && git clone -q https://git.suckless.org/dwm
base=44dbc68                                  # the fork's current base
git -C dwm log --oneline $base..HEAD          # what moved upstream
git -C dwm archive -o /tmp/dwm-new.tar HEAD   # HEAD, or a dated tag if you prefer
tar xf /tmp/dwm-new.tar
for p in /path/to/repo/patches/dwm/*.diff; do patch -p1 -i $p; done
cp /path/to/repo/src/dwm/config.def.h config.def.h   # the local config wins
cp -r . /path/to/repo/src/dwm/              # drop .git/
```

Then update this file's table and re-run **Verify**. Expect the suckless patch files
to need refreshing on every rebase -- they are user-contributed, so they go stale
against upstream master.
