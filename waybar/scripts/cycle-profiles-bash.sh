#!/usr/bin/env bash

# Extract available profiles from powerprofilesctl list
mapfile -t profiles < <(powerprofilesctl list | grep -E '^\*?[[:space:]]*[a-z-]+:$' | sed 's/^[*[:space:]]*//; s/:$//')

if [[ ${#profiles[@]} -eq 0 ]]; then
    echo " No profiles"
    exit 1
fi

current=$(powerprofilesctl get)
current_idx=-1

# Find current profile index
for i in "${!profiles[@]}"; do
    [[ "${profiles[$i]}" == "$current" ]] && { current_idx=$i; break; }
done

# Cycle to next
next_idx=$(( (current_idx + 1) % ${#profiles[@]} ))
next="${profiles[$next_idx]}"
powerprofilesctl set "$next"
