#!/bin/sh
IFACE=$(ip route get 1 2>/dev/null | awk '{print $5; exit}')
[ -z "$IFACE" ] && echo "[󰖪]" && exit 0
STATE=$(cat "/sys/class/net/$IFACE/operstate" 2>/dev/null)
if [ "$STATE" = "up" ]; then
  TYPE=$(cat "/sys/class/net/$IFACE/type" 2>/dev/null)
  if [ "$TYPE" = "1" ]; then
    SIGNAL=$(iwconfig "$IFACE" 2>/dev/null | awk '/Quality=/{split($2,a,"="); split(a[2],b,"/"); printf "%d", b[1]*100/b[2]}')
    if [ -z "$SIGNAL" ]; then
      echo "[  󰤨   ]"
    elif [ "$SIGNAL" -gt 75 ]; then
      echo "[  󰤨   ]"
    elif [ "$SIGNAL" -gt 50 ]; then
      echo "[  󰤥   ]"
    elif [ "$SIGNAL" -gt 25 ]; then
      echo "[  󰤢   ]"
    else
      echo "[  󰤟   ]"
    fi
  else
    echo "[  󰀂   ]"
  fi
else
  echo "[  󰖪   ]"
fi
