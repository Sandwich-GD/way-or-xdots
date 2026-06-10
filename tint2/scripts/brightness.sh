#!/bin/bash
brightness=$(brightnessctl get)
max_brightness=$(brightnessctl max)
percent=$((brightness * 100 / max_brightness))
filled=$((percent / 10))
empty=$((10 - filled))
bar=$(printf '█%.0s' $(seq 1 $filled))
pad=$(printf '░%.0s' $(seq 1 $empty))

if [ "$percent" -lt 20 ]; then
  echo "<span foreground='#bf616a'>󰛨 [$bar$pad] $percent%</span>"
elif [ "$percent" -lt 55 ]; then
  echo "<span foreground='#fab387'>󰛨 [$bar$pad] $percent%</span>"
else
  echo "<span foreground='#56b6c2'>󰛨 [$bar$pad] $percent%</span>"
fi
