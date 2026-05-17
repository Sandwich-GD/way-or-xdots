#!/usr/bin/env python3
import subprocess
import sys

def get_profiles():
    """Get list of available profiles."""
    try:
        output = subprocess.check_output(
            ["powerprofilesctl", "list"], text=True
        )
        profiles = []
        for line in output.splitlines():
            if line.startswith("*"):
                # Current profile line looks like: "* performance:"
                continue 
            if ":" in line:
                # Profile line looks like: "  performance:"
                name = line.strip().rstrip(":")
                if name:
                    profiles.append(name)
        return profiles
    except Exception:
        return []

def get_current():
    """Get current active profile."""
    try:
        output = subprocess.check_output(
            ["powerprofilesctl", "get"], text=True
        ).strip()
        return output
    except Exception:
        return "unknown"

def set_profile(profile):
    """Set the power profile."""
    subprocess.run(["powerprofilesctl", "set", profile])

def main():
    profiles = get_profiles()
    if not profiles:
        print("No profiles found")
        sys.exit(1)

    current = get_current()
    
    # Find index of current profile
    try:
        idx = profiles.index(current)
    except ValueError:
        idx = -1

    # Cycle to next
    next_idx = (idx + 1) % len(profiles)
    next_profile = profiles[next_idx]
    
    set_profile(next_profile)
    
    # Print for Waybar
    # You can customize the output format here
    icons = {
        "performance": "",  # Bolt
        "balanced": "",     # Scale/Balance
        "power-saver": ""   # Leaf/Eco
    }
    icon = icons.get(next_profile, "")
    print(f"{icon} {next_profile}")

if __name__ == "__main__":
    main()
