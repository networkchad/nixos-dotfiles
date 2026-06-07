#!/bin/sh

# Get the volume and check if it's muted
volume=$(amixer get Master | grep -oP '\d+%' | head -n1)
mute=$(amixer get Master | grep -oP '\[on\]|\[off\]' | head -n1)

# Check if muted, and update the output accordingly
if [ "$mute" = "[off]" ]; then
    echo "Vol:/"
else
    echo "Vol:$volume"
fi
