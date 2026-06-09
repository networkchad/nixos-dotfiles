#!/bin/sh

# Check if any VPN is active
vpn_status=$(nmcli -t -f NAME,TYPE,STATE c show --active | grep -E 'vpn|wireguard' | cut -d':' -f2)

if [ -n "$vpn_status" ]; then
  # VPN is active
  vpn_info=""
  if echo "$vpn_status" | grep -q 'vpn'; then
    # OpenVPN is active
    vpn_info="${vpn_info}OV"
  fi
  if echo "$vpn_status" | grep -q 'wireguard'; then
    # WireGuard is active
    if [ -n "$vpn_info" ]; then
      vpn_info="${vpn_info}/WG"  # If both VPNs are active
    else
      vpn_info="${vpn_info}WG"    # If only WireGuard is active
    fi
  fi
  echo "VPN:$vpn_info"  # You can customize this symbol to match your dwmblocks icons
else
  # No VPN is active
  echo "VPN:/"  # You can customize this symbol to match your dwmblocks icons
fi

