#!/bin/sh

vpn_status=$(nmcli -t -f NAME,TYPE,STATE c show --active | grep -E 'vpn|wireguard' | cut -d':' -f2)

if [ -n "$vpn_status" ]; then
  vpn_info=""
  if echo "$vpn_status" | grep -q 'vpn'; then
    vpn_info="${vpn_info}OV"
  fi
  if echo "$vpn_status" | grep -q 'wireguard'; then
    if [ -n "$vpn_info" ]; then
      vpn_info="${vpn_info}/WG"
    else
      vpn_info="${vpn_info}WG"
    fi
  fi
  echo "VPN:$vpn_info"
else
  echo "VPN:/"
fi

