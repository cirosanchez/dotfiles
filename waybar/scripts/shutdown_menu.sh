#!/usr/bin/env bash

option=$(printf "Shutdown\nReboot\nSuspend" | rofi \
    -dmenu \
    -theme /home/ciro/.config/themes/current/rofi.rasi \
    -p "")

case "$option" in
    Shutdown)
        systemctl poweroff
        ;;
    Reboot)
        systemctl reboot
        ;;
    Suspend)
        systemctl suspend
        ;;
esac