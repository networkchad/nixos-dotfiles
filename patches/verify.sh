#!/usr/bin/env bash
# Verify every non-config vendored file against its recorded base and patches.
set -euo pipefail

root=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/nixos-dotfiles-forks.XXXXXX")
trap 'rm -rf "$work"' EXIT

declare -Ar bases=(
  [dwm]=44dbc68
  [st]=688f70a
  [slock]=3791a99
  [slstatus]=614c275
)
declare -Ar patches=(
  [dwm]="dwm/uselessgap.diff"
  [st]="st/alpha.diff st/scrollback.diff st/scrollback-mouse.diff"
  [slock]=""
  [slstatus]=""
)

for pkg in dwm st slock slstatus; do
  printf 'verifying %s at %s\n' "$pkg" "${bases[$pkg]}"

  git clone --quiet --no-checkout "https://git.suckless.org/$pkg" "$work/$pkg.git"
  mkdir "$work/$pkg"
  git -C "$work/$pkg.git" archive "${bases[$pkg]}" | tar -x -C "$work/$pkg"

  # The values are whitespace-separated paths; repository paths contain no spaces.
  for patch_path in ${patches[$pkg]}; do
    patch --silent --no-backup-if-mismatch --directory "$work/$pkg" --strip=1 \
      --input "$root/patches/$patch_path"
  done

  # Compare copies so exclusions are exact top-level paths, not basename globs
  # that could also hide an unexpected nested scripts directory.
  mkdir "$work/$pkg.local"
  cp -a "$root/src/$pkg/." "$work/$pkg.local/"
  rm "$work/$pkg/config.def.h" "$work/$pkg.local/config.def.h"
  if [[ $pkg == slstatus ]]; then
    rm -rf "$work/$pkg/scripts" "$work/$pkg.local/scripts"
  fi

  # Everything except the declared local config (and slstatus's local scripts)
  # must equal upstream plus the recorded patches.
  if ! diff --recursive "$work/$pkg" "$work/$pkg.local"; then
    printf 'error: %s differs from its declared provenance\n' "$pkg" >&2
    exit 1
  fi
done

printf 'all vendored trees match their declared provenance\n'
