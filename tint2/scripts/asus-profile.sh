#!/bin/bash
profile=$(powerprofilesctl get 2>/dev/null)
case "$profile" in
  performance) echo "<span foreground='#bf616a'>Hardcore Inteling</span>" ;;
  balanced)    echo "<span foreground='#fab387'>Balanced</span>" ;;
  power-saver) echo "<span foreground='#56b6c2'>Saving volts</span>" ;;
  *)           echo "Regular" ;;
esac
