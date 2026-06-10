#!/bin/bash
vol_raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{ print $2 }')
vol_int=$(echo "$vol_raw * 100" | bc | awk '{ print int($1) }')
is_muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo true || echo false)

if [ "$is_muted" = true ]; then
  vol_int=0
fi

filled=$((vol_int / 10))
empty=$((10 - filled))
bar=$(printf '█%.0s' $(seq 1 $filled))
pad=$(printf '░%.0s' $(seq 1 $empty))

if [ "$is_muted" = true ] || [ "$vol_int" -lt 10 ]; then
  echo "<span foreground='#bf616a'>[ ] $bar$pad $vol_int%</span>"
elif [ "$vol_int" -lt 50 ]; then
  echo "<span foreground='#fab387'>[ ] $bar$pad $vol_int%</span>"
else
  echo "<span foreground='#56b6c2'>[ ] $bar$pad $vol_int%</span>"
fi
