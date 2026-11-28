#!/bin/sh
# Render the whole bar through slstatus's single run_command component.
# slstatus has one single-threaded global interval, so one executable avoids a
# fork per segment. Keep shell-backed entries adjacent in config.def.h args[];
# CPU/RAM entries before or after this one determine their side of the bar.
# This is an executable runtime file, not a build input: home-manager links it,
# so the shebang and Git mode 100755 are required.

set -u

sep=" | "
out="NixOS"

# VPN: comma-join classes with scope-global addresses, or "/" for none.
# A logged-out tailscaled has no global address and is therefore down.
# Classify standard device names: tailscale*, wg*, tun*, ovpn*. Renamed/tap devices
# and tunnels with only link-local addresses are not reported.
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

# Internet heuristic: an IPv4 default route whose device has operstate=up;
# this avoids blocking probes but does not prove Internet reachability.
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

# Join BAT* capacities with "/"; omit the segment when there are none.
bats=""
for battery in /sys/class/power_supply/BAT?*; do
	[ -r "$battery/capacity" ] || continue
	if IFS= read -r capacity <"$battery/capacity"; then
		[ -n "$bats" ] && bats="$bats/"
		bats="$bats$capacity%"
	fi
done
[ -n "$bats" ] && out="$out${sep}B:$bats"

# Volume: "/" is muted and "?" means no Master control. Do not add -q:
# `amixer -q get Master` can print nothing; quiet mode belongs on `set`.
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
