#!/usr/bin/env bash

wallpaper="$1"

current_theme=$(python ~/.config/themes/get_current_theme.py)

python ~/.config/themes/set_wallpaper.py "$current_theme" "$wallpaper"