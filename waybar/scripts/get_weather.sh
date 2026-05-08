#!/usr/bin/env bash

LAT="4.7110"
LON="-74.0721"
CITY="Bogotá"

CACHE="/tmp/waybar-weather.json"

API="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m,pressure_msl&hourly=temperature_2m,precipitation_probability,weather_code,visibility,uv_index&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_probability_max&forecast_days=8&timezone=auto"

# Refresh cache every 15 min
if [[ ! -f "$CACHE" ]] || [[ $(find "$CACHE" -mmin +15 2>/dev/null) ]]; then
    curl -s "$API" > "$CACHE"
fi

data=$(cat "$CACHE")

if [[ -z "$data" ]]; then
    echo '{"text":"Weather Error","tooltip":"Weather Error"}'
    exit 1
fi

weather_icon() {
    local code=$1
    local is_day=$2

    case $code in
        0)
            [[ $is_day == 1 ]] && echo "󰖙" || echo "󰖔"
            ;;
        1|2)
            [[ $is_day == 1 ]] && echo "󰖕" || echo "󰼱"
            ;;
        3)
            echo "󰖐"
            ;;
        45|48)
            echo "󰖑"
            ;;
        51|53|55|56|57|61|63|65|80|81|82)
            echo "󰖗"
            ;;
        66|67)
            echo "󰙿"
            ;;
        71|73|75|77|85|86)
            echo "󰼶"
            ;;
        95|96|99)
            echo "󰖓"
            ;;
        *)
            echo "󰖐"
            ;;
    esac
}

weather_desc() {
    case $1 in
        0) echo "Clear" ;;
        1|2) echo "Partly Cloudy" ;;
        3) echo "Cloudy" ;;
        45|48) echo "Fog" ;;
        51|53|55) echo "Drizzle" ;;
        61|63|65) echo "Rain" ;;
        71|73|75) echo "Snow" ;;
        95|96|99) echo "Thunderstorm" ;;
        *) echo "Unknown" ;;
    esac
}

# CURRENT
temp=$(echo "$data" | jq '.current.temperature_2m | round')
feels=$(echo "$data" | jq '.current.apparent_temperature | round')
humidity=$(echo "$data" | jq '.current.relative_humidity_2m')
wind=$(echo "$data" | jq '.current.wind_speed_10m | round')
pressure=$(echo "$data" | jq '.current.pressure_msl | round')
code=$(echo "$data" | jq '.current.weather_code')
is_day=$(echo "$data" | jq '.current.is_day')

icon=$(weather_icon "$code" "$is_day")
desc=$(weather_desc "$code")

# DAILY
today_max=$(echo "$data" | jq '.daily.temperature_2m_max[0] | round')
today_min=$(echo "$data" | jq '.daily.temperature_2m_min[0] | round')

sunrise=$(echo "$data" | jq -r '.daily.sunrise[0]' | cut -d'T' -f2 | cut -c1-5)
sunset=$(echo "$data" | jq -r '.daily.sunset[0]' | cut -d'T' -f2 | cut -c1-5)

uv=$(echo "$data" | jq '.daily.uv_index_max[0] | round')

rainchance=$(echo "$data" | jq '.daily.precipitation_probability_max[0] // 0')

# BAR TEXT
text="$icon  ${temp}°"

# TOOLTIP
tooltip=""

tooltip+="<span size='xx-large'>$temp°</span> ${icon}\n"
tooltip+="<b>${CITY}</b> · ${desc}\n"
tooltip+="H:${today_max}°  L:${today_min}°  Feels like ${feels}°\n\n"

tooltip+="<b>Conditions</b>\n"
tooltip+="󰖐  Humidity      ${humidity}%\n"
tooltip+="󰖗  Rain Chance   ${rainchance}%\n"
tooltip+="󰓤  Wind          ${wind} km/h\n"
tooltip+="󰇚  Pressure      ${pressure} hPa\n"
tooltip+="󰛨  UV Index      ${uv}\n"
tooltip+="󰖜  Sunrise       ${sunrise}\n"
tooltip+="󰖛  Sunset        ${sunset}\n\n"

# HOURLY FORECAST
tooltip+="<b>Hourly Forecast</b>\n"

for i in 0 2 4 6 8 10; do
    htemp=$(echo "$data" | jq ".hourly.temperature_2m[$i] | round")
    hcode=$(echo "$data" | jq ".hourly.weather_code[$i]")

    hrain=$(echo "$data" | jq ".hourly.precipitation_probability[$i] // 0")

    hicon=$(weather_icon "$hcode" 1)

    htime=$(echo "$data" | jq -r ".hourly.time[$i]" | cut -d'T' -f2 | cut -c1-5)

    tooltip+="${htime}  ${hicon}  ${htemp}°  ☔ ${hrain}%\n"
done

tooltip+="\n<b>7-Day Forecast</b>\n"

days=$(echo "$data" | jq '.daily.time | length')

for ((i=0; i<days; i++)); do

    day=$(echo "$data" | jq -r ".daily.time[$i] | strptime(\"%Y-%m-%d\") | strftime(\"%a\")")

    dmax=$(echo "$data" | jq ".daily.temperature_2m_max[$i] | round")
    dmin=$(echo "$data" | jq ".daily.temperature_2m_min[$i] | round")

    dcode=$(echo "$data" | jq ".daily.weather_code[$i]")

    drain=$(echo "$data" | jq ".daily.precipitation_probability_max[$i] // 0")

    dicon=$(weather_icon "$dcode" 1)

    tooltip+="${day}  ${dicon}  ${dmax}°/${dmin}°  ☔ ${drain}%\n"
done

tooltip+="\n<b>Summary</b>\n"

if [[ $rainchance -gt 70 ]]; then
    tooltip+="Expect rain today. Carry an umbrella."
elif [[ $temp -gt 24 ]]; then
    tooltip+="Warm conditions throughout the day."
elif [[ $temp -lt 10 ]]; then
    tooltip+="Cold weather expected today."
else
    tooltip+="Stable weather conditions today."
fi

# Escape newlines for JSON
tooltip=$(echo "$tooltip" | sed ':a;N;$!ba;s/\n/\\n/g')

echo "{\"text\":\"${text}\",\"tooltip\":\"${tooltip}\"}"