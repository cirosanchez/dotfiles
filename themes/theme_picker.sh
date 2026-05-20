#!/usr/bin/env bash

theme=$(printf "mocha\nnord\ngruvbox\nnothingos" | wofi \
    --dmenu \
    --no-search \
    --prompt "Theme" \
    --style /home/ciro/.config/themes/current/wofi.css)

[ -z "$theme" ] && exit

python /home/ciro/.config/themes/switch.py "$theme"