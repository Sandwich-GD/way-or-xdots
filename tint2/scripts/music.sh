#!/usr/bin/env python3
import subprocess, sys

def get_media():
  try:
    status = subprocess.check_output(["playerctl", "status"], stderr=subprocess.DEVNULL).decode().strip()
    if status != "Playing":
      return None
    title = subprocess.check_output(["playerctl", "metadata", "xesam:title"], stderr=subprocess.DEVNULL).decode().strip()
    artist = subprocess.check_output(["playerctl", "metadata", "xesam:artist"], stderr=subprocess.DEVNULL).decode().strip()
    if not title: title = "Unknown Title"
    if not artist: artist = "Unknown Artist"
    return f" {artist} - {title}"
  except:
    return None

info = get_media()
if info:
  print(info)
else:
  print("")
