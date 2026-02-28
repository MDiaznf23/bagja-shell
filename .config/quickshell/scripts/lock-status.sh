#!/bin/bash

# WiFi
wifi_interface="wlan0"
wifi_state=$(cat /sys/class/net/$wifi_interface/operstate 2>/dev/null)
if [ "$wifi_state" = "up" ]; then
    wifi_signal=$(nmcli -t -f SIGNAL dev wifi | head -n1 2>/dev/null)
    if [ -z "$wifi_signal" ] || ! [[ "$wifi_signal" =~ ^[0-9]+$ ]]; then
        wifi_signal=100
    fi
    if [ "$wifi_signal" -le 20 ]; then wifi_icon="󰤯"
    elif [ "$wifi_signal" -le 40 ]; then wifi_icon="󰤟"
    elif [ "$wifi_signal" -le 60 ]; then wifi_icon="󰤢"
    elif [ "$wifi_signal" -le 80 ]; then wifi_icon="󰤥"
    else wifi_icon="󰤨"; fi
else
    wifi_icon="󰤮"
fi

# Battery
bat_capacity=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)
bat_status=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null)
ac_online=$(cat /sys/class/power_supply/ADP1/online 2>/dev/null)
if [ -z "$bat_capacity" ]; then bat_capacity=0; fi
if [ "$bat_status" = "Charging" ] || [ "$ac_online" = "1" ]; then
    if [ "$bat_capacity" -le 20 ]; then bat_icon="󰢜"
    elif [ "$bat_capacity" -le 50 ]; then bat_icon="󰂈"
    elif [ "$bat_capacity" -le 80 ]; then bat_icon="󰢞"
    else bat_icon="󰂅"; fi
else
    if [ "$bat_capacity" -le 10 ]; then bat_icon="󰂎"
    elif [ "$bat_capacity" -le 30 ]; then bat_icon="󰁻"
    elif [ "$bat_capacity" -le 60 ]; then bat_icon="󰁾"
    elif [ "$bat_capacity" -le 90 ]; then bat_icon="󰂁"
    else bat_icon="󰂂"; fi
fi

# Volume
muted=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -o 'yes')
vol_pct=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -Po '\d+(?=%)' | head -1)
if [ -z "$vol_pct" ]; then vol_pct=0; fi
if [ "$muted" = "yes" ]; then vol_icon="󰖁"
elif [ "$vol_pct" -le 30 ]; then vol_icon=""
elif [ "$vol_pct" -le 70 ]; then vol_icon=""
else vol_icon=" "; fi

echo "{\"wifi\":\"$wifi_icon\",\"battery\":\"$bat_icon\",\"volume\":\"$vol_icon\"}"
