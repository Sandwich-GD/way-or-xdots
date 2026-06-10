#!/bin/sh
killall -9 tint2 2>/dev/null
while pgrep -x tint2 >/dev/null; do sleep 0.3; done
tint2 -c ~/.config/tint2/tint2rc & disown
