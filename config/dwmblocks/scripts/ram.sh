#!/bin/sh

# Calculate memoery usage
mem_per=$(free -m | awk '/^Mem/ { print int(($3/$2)*100) }')

# Output
echo "RAM:$mem_per%"
