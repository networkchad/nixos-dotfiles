#!/bin/sh
# One pass of the whole status line for dwm's bar, through slstatus's single
# `run_command` component (see ../config.def.h).
#
# One script, not one per segment, because slstatus has ONE global `interval`
# and a single-threaded main loop, and the `datetime` component wants that
# interval at 1000 ms to keep the clock honest -- so the interval is not the
# thing to fix, the number of forks inside it is. Five scripts were five
# fork+exec every second for the life of the session, serialized against the
# clock (measured before this file existed: 66-72 ms a pass ~= 7% of a core).
# This costs one shell plus one `ip` and one `amixer`, the rest being builtins
# and /sys reads: 9-13 ms a pass, same 1000 ms, same bar.
#
# Called as a program by config.def.h (slstatus runs the argument through
# `sh -c` itself), which needs this shebang and the file's exec bit -- git mode
# 100755, and home-manager symlinks it, so the mode travels.
#
# Ordering constraint that comes with it: every shell-backed segment has to be
# adjacent in args[], because they are one string now. CPU/RAM sit after this
# one; move those two lines above it in config.def.h to put them on the left.
#
# Runtime file, not a build input: the overlay in ../../../modules/system/forks.nix
# filters scripts/ out of the slstatus derivation and ../../../modules/home/desktop.nix
# links this directory to ~/.config/slstatus/scripts.

set -u

sep=" | "
out="NixOS"

# VPN: tailscale's own interface.
#
# The old vpn.sh asked NetworkManager (`nmcli ... | grep -E 'vpn|wireguard'`),
# which can never match: NM lists tailscale0 as `tailscale0:tun:activated`, so
# the segment read "/" on every host even with the tunnel up. tailscale is not
# an NM VPN connection and never will be. A logged-out daemon keeps the link but
# has no address, so the test is tailscale's own CGNAT /10 (100.64.0.0/10),
# matched with a case pattern instead of a grep fork.
#
# NM-managed VPNs (openconnect, wireguard-go via NM) are NOT reported. If one is
# ever needed, that is the place for the nmcli fork:
#     nmcli -t -f TYPE,STATE c show --active | grep -q 'vpn:activated' && vpn=OV
vpn="/"
if [ -e /sys/class/net/tailscale0 ]; then
	case "$(ip -o -4 addr show dev tailscale0 2>/dev/null)" in
	*" 100."*) vpn="TS" ;;
	esac
fi
out="$out${sep}VPN:$vpn"

# Internet: a default route whose device reports carrier.
#
# The old internet.sh ran `ping -c 1 -W 1 nixos.org`, which was wrong twice: it
# blocked slstatus's main loop for the whole timeout (freezing every other
# segment, and seconds more while the resolver gave up), and it tested one fixed
# hostname, so a captive portal answered and said "On". This says what it means:
# the main routing table has a default route and the device behind it is up.
net="Off"
defdev=""
while read -r iface dest _rest; do
	[ "$dest" = "00000000" ] && defdev="$iface" && break
done </proc/net/route
if [ -n "$defdev" ] && [ -r "/sys/class/net/$defdev/operstate" ]; then
	IFS= read -r state <"/sys/class/net/$defdev/operstate"
	[ "$state" = "up" ] && net="On"
fi
out="$out${sep}Net:$net"

# Battery: one segment per BAT?, joined with "/".
#
# Nothing here needs the old empty-output workaround (battery.sh printed a space
# so slstatus would not fall back to "n/a" on a desktop): this script always
# emits a full line, so a machine with no battery simply gets no " | B:" part.
bats=""
for battery in /sys/class/power_supply/BAT?*; do
	[ -r "$battery/capacity" ] || continue
	if IFS= read -r capacity <"$battery/capacity"; then
		[ -n "$bats" ] && bats="$bats/"
		bats="$bats$capacity%"
	fi
done
[ -n "$bats" ] && out="$out${sep}B:$bats"

# Volume: one `amixer` call, parsed by the shell.
#
# volume.sh ran `amixer get Master` twice and piped each into `grep -oP` and
# `head` -- four extra processes to say the same thing. Muted is still "/", the
# dwm mute binding's own visual state, and "?" means "no Master control" (the
# old scripts let the empty string fall through to slstatus's unknown_str, which
# is not available to a component that also prints the rest of the line).
#
# No -q here, unlike the dwm bindings: `amixer -q get Master` prints NOTHING on
# alsa-utils 1.2.14 (verified), so quiet is for `set`, not for `get`.
vol="?"
# shellcheck disable=SC2046 # word splitting is the parser here
set -- $(amixer get Master 2>/dev/null)
pct=""
muted=""
for token in "$@"; do
	case "$token" in
	\[*%\])
		pct="${token#\[}"
		pct="${pct%\%\]}"
		;;
	\[off\]) muted=1 ;;
	esac
done
if [ -n "$pct" ]; then
	if [ -n "$muted" ]; then
		vol="/"
	else
		vol="$pct%"
	fi
fi
out="$out${sep}Vol:$vol"

printf '%s\n' "$out"
