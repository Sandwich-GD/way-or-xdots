#!/bin/bash
active=$(hyprctl activeworkspace -j | jq '.id')
if [ "$active" -eq 1 ]; then
  echo "<span foreground='#CBC3E3'>●</span>"
else
  echo "А"
fi
