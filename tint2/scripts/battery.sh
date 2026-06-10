#!/bin/bash
capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 0)

filled=$((capacity / 10))
empty=$((10 - filled))
bar=$(printf '█%.0s' $(seq 1 $filled))
pad=$(printf '░%.0s' $(seq 1 $empty))

if [ "$capacity" -lt 20 ]; then
  echo "<span foreground='#bf616a'>[ ] $bar$pad $capacity%</span>"
elif [ "$capacity" -lt 55 ]; then
  echo "<span foreground='#fab387'>[ ] $bar$pad $capacity%</span>"
else
  echo "<span foreground='#56b6c2'>[ ] $bar$pad $capacity%</span>"
fi
