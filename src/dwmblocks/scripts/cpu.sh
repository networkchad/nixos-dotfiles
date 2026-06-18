#!/bin/sh

# Get the CPU idle percentage from top output
idle=$(top -bn1 | grep "^%Cpu" | awk '{print $8}' | sed 's/,//')

# Calculate CPU usage = 100 - idle, integer arithmetic
idle_int=${idle%.*}
cpu_usage=$((100 - idle_int))

echo "CPU:$cpu_usage%"

