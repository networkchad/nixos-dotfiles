#!/bin/sh

idle=$(top -bn1 | grep "^%Cpu" | awk '{print $8}' | sed 's/,//')

idle_int=${idle%.*}
cpu_usage=$((100 - idle_int))

echo "CPU:$cpu_usage%"

