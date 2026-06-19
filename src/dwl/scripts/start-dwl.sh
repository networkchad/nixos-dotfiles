#!/bin/sh

fcitx5 -d &

swayidle -w \
    timeout 300 'swaylock -f' \
    before-sleep 'swaylock -f' &

slstatus -s &

exec dwl
