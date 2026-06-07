#!/bin/sh

# Prints all batteries with their percentage remaining.

# Loop through all attached batteries and format the info
for battery in /sys/class/power_supply/BAT?*; do
	[ -n "${capacity+x}" ] && printf " "
	case "$(cat "$battery/status" 2>&1)" in
		"Full") status="F" ;;
		"Discharging") status="B" ;;
		"Charging") status="C" ;;
		"Not charging") status="N" ;;
		"Unknown") status="S" ;;
		*) exit 1 ;;
	esac
	capacity="$(cat "$battery/capacity" 2>&1)"
	printf "%s:%d%%" "$status" "$capacity"
done && printf "\n"
