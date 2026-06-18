#!/bin/sh

ping_target="nixos.org"

ping -c 1 -W 1 "$ping_target" > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "Net:On"
else
  echo "Net:Off"
fi

