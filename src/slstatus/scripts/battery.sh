#!/bin/sh
# Battery segment for dwm's status area, run through slstatus's `run_command`
# (see ../config.def.h).
#
# The segment prints its own " | B:" separator because its format string is
# plain "%s": on a machine with no battery the whole segment has to disappear,
# which a compiled-in `battery_perc`/BAT0 cannot do -- it would print "n/a", and
# the name BAT0 is only true for the laptop.

out=""
for battery in /sys/class/power_supply/BAT?*; do
	[ -r "$battery/capacity" ] || continue
	capacity=$(cat "$battery/capacity" 2>/dev/null) || continue
	[ -n "$out" ] && out="$out/"
	out="$out$capacity%"
done

# Empty output makes slstatus fall back to its unknown_str ("n/a"), so the
# no-battery case emits a space instead: invisible in the bar.
if [ -n "$out" ]; then
	printf " | B:%s\n" "$out"
else
	printf " \n"
fi
