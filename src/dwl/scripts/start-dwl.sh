#!/bin/sh

dwl &
fcitx5 -d &
swaybg -i "$HOME/.config/wallpapers/2077.png" -m fill &

swayidle -w \
    timeout 300 'swaylock -f' \
    before-sleep 'swaylock -f' &

exec slstatus -s
