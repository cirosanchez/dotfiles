#!/usr/bin/env bash

BAT="/sys/class/power_supply/BAT1"

capacity=$(cat "$BAT/capacity")
status=$(cat "$BAT/status")

energy_now=$(cat "$BAT/energy_now" 2>/dev/null || cat "$BAT/charge_now")
energy_full=$(cat "$BAT/energy_full" 2>/dev/null || cat "$BAT/charge_full")

power_now=$(cat "$BAT/power_now" 2>/dev/null || cat "$BAT/current_now")

# Icons
if [[ "$status" == "Charging" ]]; then
    icon="󰂄"
elif [[ "$capacity" -ge 95 ]]; then
    icon="󰁹"
elif [[ "$capacity" -ge 80 ]]; then
    icon="󰂂"
elif [[ "$capacity" -ge 60 ]]; then
    icon="󰂀"
elif [[ "$capacity" -ge 40 ]]; then
    icon="󰁾"
elif [[ "$capacity" -ge 20 ]]; then
    icon="󰁼"
else
    icon="󰁺"
fi

# Time estimation
time_text="Unknown"

if [[ "$power_now" -gt 0 ]]; then

    if [[ "$status" == "Discharging" ]]; then
        seconds=$(( energy_now * 3600 / power_now ))
        hours=$(( seconds / 3600 ))
        mins=$(( (seconds % 3600) / 60 ))

        time_text="${hours}h ${mins}m remaining"

    elif [[ "$status" == "Charging" ]]; then
        remaining=$(( energy_full - energy_now ))

        seconds=$(( remaining * 3600 / power_now ))
        hours=$(( seconds / 3600 ))
        mins=$(( (seconds % 3600) / 60 ))

        time_text="${hours}h ${mins}m until full"
    fi
fi

tooltip="<b>Battery</b>\n"
tooltip+="Status: ${status}\n"
tooltip+="Charge: ${capacity}%\n"
tooltip+="Time: ${time_text}"

tooltip=$(echo "$tooltip" | sed ':a;N;$!ba;s/\n/\\n/g')

echo "{\"text\":\"${icon} ${capacity}%\",\"tooltip\":\"${tooltip}\"}"P