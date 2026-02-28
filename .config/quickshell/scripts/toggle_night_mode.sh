#!/bin/bash

STATUS_FILE="/tmp/night_mode_status"

if [ -f "$STATUS_FILE" ] && [ "$(cat $STATUS_FILE)" = "on" ]; then
    pkill -x wlsunset
    echo "off" > "$STATUS_FILE"
else
    wlsunset -t 3400 -T 3401 &
    echo "on" > "$STATUS_FILE"
fi
