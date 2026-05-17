#!/usr/bin/env python3
import subprocess
import json
import sys

def get_media_info():
    try:
        # Check if any player is playing
        status = subprocess.check_output(
            ["playerctl", "status"], stderr=subprocess.DEVNULL
        ).decode().strip()
        
        if status != "Playing":
            return None

        # Get metadata
        title = subprocess.check_output(
            ["playerctl", "metadata", "xesam:title"], stderr=subprocess.DEVNULL
        ).decode().strip()
        
        artist = subprocess.check_output(
            ["playerctl", "metadata", "xesam:artist"], stderr=subprocess.DEVNULL
        ).decode().strip()
        
        # Handle multiple artists or empty fields
        if not title:
            title = "Unknown Title"
        if not artist:
            artist = "Unknown Artist"
        elif "," in artist:
            artist = artist.split(",")[0] # Take first artist if multiple

        return {
            "text": f" {artist} - {title}",
            "alt": f"{title} by {artist}",
            "tooltip": f"<b>{title}</b>\n<i>{artist}</i>",
            "class": "custom-media"
        }
    except subprocess.CalledProcessError:
        return None

if __name__ == "__main__":
    info = get_media_info()
    if info:
        print(json.dumps(info))
    else:
        # Output empty JSON to hide module or show placeholder
        print(json.dumps({"text": "", "class": "custom-media-hidden"}))
