#!/bin/bash
active=$(hyprctl activeworkspace -j | jq '.id')
if [ "$active" -eq 3 ]; then
  echo "<span foreground='#CBC3E3'>●</span>"
else
  echo "C"
fi
