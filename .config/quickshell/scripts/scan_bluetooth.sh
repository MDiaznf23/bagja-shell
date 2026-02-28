#!/bin/bash

# Check if bluetooth is powered
powered=$(busctl get-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered 2>/dev/null | awk '{print $2}')
if [ "$powered" != "true" ]; then
    echo "[]"
    exit 0
fi

devices_json="["
first=true

# Ambil semua device dari DBus langsung
while read -r mac_path; do
    mac_formatted=$(basename "$mac_path" | sed 's/dev_//')
    mac=$(echo "$mac_formatted" | tr '_' ':')
    
    # Ambil properties via busctl
    name=$(busctl get-property org.bluez "$mac_path" org.bluez.Device1 Name 2>/dev/null | sed 's/s "//' | sed 's/"$//')
    paired=$(busctl get-property org.bluez "$mac_path" org.bluez.Device1 Paired 2>/dev/null | awk '{print $2}')
    dev_conn=$(busctl get-property org.bluez "$mac_path" org.bluez.Device1 Connected 2>/dev/null | awk '{print $2}')
    media_conn=$(busctl get-property org.bluez "$mac_path" org.bluez.MediaControl1 Connected 2>/dev/null | awk '{print $2}')
    icon=$(busctl get-property org.bluez "$mac_path" org.bluez.Device1 Icon 2>/dev/null | awk '{print $2}' | tr -d '"')

    [ -z "$name" ] && continue

    # connected kalau salah satu true
    if [ "$dev_conn" = "true" ] || [ "$media_conn" = "true" ]; then
        connected="true"
    else
        connected="false"
    fi

    case "$icon" in
        *phone*|*mobile*) type_icon="phone" ;;
        *audio*|*headset*|*headphone*) type_icon="headphone" ;;
        *computer*) type_icon="computer" ;;
        *keyboard*) type_icon="keyboard" ;;
        *mouse*) type_icon="mouse" ;;
        *) type_icon="device" ;;
    esac

    name_escaped=$(echo -n "$name" | sed 's/\\/\\\\/g; s/"/\\"/g')

    if [ "$first" = false ]; then
        devices_json+=","
    fi
    devices_json+="{\"name\":\"$name_escaped\",\"mac\":\"$mac\",\"connected\":$connected,\"paired\":${paired:-false},\"type\":\"$type_icon\"}"
    first=false

done < <(busctl tree org.bluez 2>/dev/null | grep -o '/org/bluez/hci0/dev_[A-Z0-9_]*$')

devices_json+="]"
echo "$devices_json"
