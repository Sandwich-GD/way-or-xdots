#!/bin/bash
if rfkill list bluetooth 2>/dev/null | grep -q "Soft blocked: no"; then
  echo "<span foreground='#56b6c2'></span>"
else
  echo "<span foreground='#bf616a'>󰂲</span>"
fi
