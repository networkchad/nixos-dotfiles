#!/bin/sh
fcitx5 -d &

sleep 0.1

swaybg -i "$HOME/.config/wallpapers/2077.png" -m fill &

slstatus -s | exec dwl
