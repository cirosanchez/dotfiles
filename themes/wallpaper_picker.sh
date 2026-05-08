#!/usr/bin/env bash

current_theme=$(python /home/ciro/.config/themes/get_current_theme.py)

selected=$(
find "/home/ciro/Pictures/$current_theme" \
\( \
-iname "*.png" \
-o -iname "*.jpg" \
-o -iname "*.jpeg" \
-o -iname "*.webp" \
\) \
| sort \
| while read img; do
    printf "img:%s:text:%s\n" "$img" "$(basename "$img")"
done \
| wofi \
    --dmenu \
    --allow-images \
    --image-size 160 \
    --prompt "Wallpaper" \
    --style /home/ciro/.config/themes/current/wofi.css 
)

[ -z "$selected" ] && exit

wallpaper=$(echo "$selected" | sed 's/^img:\(.*\):text:.*/\1/')

python /home/ciro/.config/themes/set_wallpaper.py \
    "$current_theme" \
    "$wallpaper"