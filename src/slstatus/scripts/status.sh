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

# VPN: one token per tunnel class that carries traffic, comma-joined --
# `VPN:TS,WG` with tailscale and a wireguard interface up, `/` with none.
#
# The old vpn.sh asked NetworkManager (`nmcli ... | grep -E 'vpn|wireguard'`),
# which can never match tailscale: NM lists it as `tailscale0:tun:activated`, so
# the segment read "/" on every host even with the tunnel up. tailscale is not an
# NM VPN connection and never will be. nmcli is also the slower answer to the
# same question (26 ms of D-Bus versus 2 ms for `ip`, measured on this box) and
# it reports every plugin as the bare type `vpn`, so openvpn and openconnect are
# indistinguishable in it. Kernel state answers for all three classes in the one
# `ip` fork the segment already paid for.
#
# The test per interface is the one the tailscale case already used -- a scope
# global address, because a logged-out tailscaled keeps the link with none. The
# CGNAT literal went with it: an address is an address, and a tailnet outside
# 100.64.0.0/10 used to read as no VPN at all.
#
# The class comes from the interface name, because the kernel records no class:
# tailscale0 here is an ordinary tun -- 65534 (ARPHRD_NONE) in
# /sys/class/net/tailscale0/type, `ip -d link` says `tun type tun`, which is
# exactly why NM advertises it as `tailscale0:tun` -- and a wireguard device
# reports the same 65534. So the name is the only handle the bar has: wg* is what
# `networking.wireguard.interfaces.wg0` and NM's native wireguard create, tun* is
# `openvpn --dev tun` and the openvpn plugin's device, ovpn* is the name newer
# NetworkManager gives that same plugin. What this cannot see is a config that
# renames its device (`dev-node`, or `--dev tap`, which makes a tap0) -- and an
# interface whose only address is link-local, which is reported as down because it
# is: nothing is being tunnelled through it.
vpn="/"
addrs=$(ip -o addr show scope global 2>/dev/null)
# shellcheck disable=SC2086 # word splitting is the parser here, twice over
for class in "TS tailscale*" "WG wg*" "OV tun* ovpn*"; do
	tag=${class%% *}
	on=""
	# shellcheck disable=SC2086,SC2231 # and the glob has to stay a glob
	for pattern in ${class#* }; do
		for dev in /sys/class/net/$pattern; do
			[ -e "$dev" ] || continue
			case "$addrs" in
			*" ${dev##*/} "*inet*) on=1 ;;
			esac
		done
	done
	if [ -n "$on" ]; then
		if [ "$vpn" = "/" ]; then
			vpn=$tag
		else
			vpn="$vpn,$tag"
		fi
	fi
done
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
