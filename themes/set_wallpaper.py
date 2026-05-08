#!/usr/bin/env python3

from pathlib import Path
import json
import subprocess
import sys

if len(sys.argv) != 3:
    exit(1)

THEMES = Path.home() / ".config/themes"
STATE = THEMES / "state.json"

theme = sys.argv[1]
wallpaper = sys.argv[2]

if STATE.exists():
    with open(STATE) as f:
        state = json.load(f)
else:
    state = {
        "current_theme": theme,
        "wallpapers": {}
    }

state["wallpapers"][theme] = wallpaper
state["current_theme"] = theme

with open(STATE, "w") as f:
    json.dump(state, f, indent=4)

subprocess.run([
    "awww",
    "img",
    wallpaper,
    "--transition-type",
    "grow",
    "--transition-duration",
    "1"
])