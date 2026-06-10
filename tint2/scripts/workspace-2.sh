#!/bin/bash
active=$(hyprctl activeworkspace -j | jq '.id')
if [ "$active" -eq 2 ]; then
  echo "<span foreground='#CBC3E3'>●</span>"
else
  echo "B"
fi
