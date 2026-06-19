#!/bin/sh

mem_per=$(free -m | awk '/^Mem/ { print int(($3/$2)*100) }')

echo "RAM:$mem_per%"
