#!/bin/bash

BARS=16

while true; do
    PLAYER_STATUS=$(playerctl status 2>/dev/null)

    if [ "$PLAYER_STATUS" = "Playing" ]; then
        out=""
        for ((i=0; i<BARS; i++)); do
            val=$((RANDOM % 100))
            out+="$val;"
        done
        echo "$out"
        sleep 0.05
    else
        out=""
        for ((i=0; i<BARS; i++)); do 
            out+="0;" 
        done
        echo "$out"
        sleep 0.5
    fi
done
