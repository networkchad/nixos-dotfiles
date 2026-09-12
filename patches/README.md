# Patch provenance

The forks in `../src` carry these changes **in the source itself** — the
build never applies them (`overlays/vendored.nix` sets `patches = [ ]` so
upstream's patch list cannot be applied on top of hand-modified code).

Kept here for two reasons: they document where each local change came from,
and they are what you re-apply when rebasing a fork onto a new upstream
release. They are deliberately outside `../src` so editing them cannot
invalidate a derivation and trigger a WM rebuild.

| file | upstream base | status | where it lives in the fork |
| --- | --- | --- | --- |
| `dwl/bar.patch` | 0.8 | applied | `src/dwl/dwl.c` (`bar_init`, `updatebar`) — this is what lets `slstatus -s \| dwl` feed a bar |
| `dwl/gaps.patch` | 0.8 | applied | `src/dwl/dwl.c`, `src/dwl/config.def.h` (`gaps`) |
| `dwl/autostart.patch` | 0.8 | applied | `src/dwl/dwl.c` (`autostartexec`), `config.def.h` (`autostart[]`) |
| `dwm/uselessgap.diff` | 6.6 | applied | `src/dwm/dwm.c` (`gappx`), `config.def.h` (`gappx = 6`) |
| `st/alpha.diff` | 0.9.2 | applied | `src/st/x.c`, `src/st/config.def.h` (`float alpha = 0.7`) |
| `st/scrollback.diff` | 0.9.2 | applied | `src/st/st.c` (`HISTSIZE`, `kscrollup/kscrolldown`), `st.h`, `config.def.h` (Shift+PageUp/Down, Ctrl+wheel) |
| `st/scrollback-mouse.diff` | 0.9.2 | **not applied** | kept for reference: plain wheel-to-history is not wired into `src/st/x.c`; scrollback is reached with Ctrl+wheel or Shift+PageUp/Down |
