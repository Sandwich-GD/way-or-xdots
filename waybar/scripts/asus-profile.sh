#!/bin/bash
# ── asus-profile.sh ───────────────────────────────────────  
# Description: Display current ASUS power profile with color
# Usage: Called by Waybar `custom/asus-profile`
# Dependencies: asusctl, awk
# ──────────────────────────────────────────────────────────  

profile=$(powerprofilesctl get)

case "$profile" in
  performance)
    text="Hardcore Inteling"
    fg="#bf616a"
    ;;
  balanced)
    text="Balanced"
    fg="#fab387"
    ;;
  power-saver)
    text="Saving volts"
    fg="#56b6c2"
    ;;
  *)
    text="Regular"
    fg="#ffffff"
    ;;
esac

echo "<span foreground='$fg'>$text</span>"

