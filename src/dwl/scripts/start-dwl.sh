#!/bin/sh

pkill fcitx5
pkill swaybg
pkill slstatus

fcitx5 -d &

slstatus &

swaybg -i "$HOME/.config/wallpapers/2077.png" -m fill &
