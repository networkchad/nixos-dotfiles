#!/bin/sh

# Define the target server to ping (you can use a reliable server like Google's DNS)
ping_target="8.8.8.8"

# Ping the target with a single packet and suppress output
ping -c 1 -W 1 "$ping_target" > /dev/null 2>&1

# Check the exit status of the ping command
if [ $? -eq 0 ]; then
  # Internet is on
  echo "Net:On"  # You can customize this symbol to match your dwmblocks icons
else
  # Internet is off
  echo "Net:Off"  # You can customize this symbol to match your dwmblocks icons
fi

