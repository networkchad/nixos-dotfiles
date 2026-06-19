#!/bin/sh

fcitx5 -d &
slstatus &

swaybg -i "$HOME/.config/wallpapers/2077.png" -m fill &

exec dwl
