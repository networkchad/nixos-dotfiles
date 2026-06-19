#!/bin/sh
pkill fcitx5
pkill swaybg
pkill slstatus

fcitx5 -d &
swaybg -i "$HOME/.config/wallpapers/2077.png" -m fill &

slstatus -s | exec dwl
