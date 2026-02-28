#!/bin/bash

BAT_NAME=$(cat /sys/class/power_supply/BAT*/model_name | head -n 1 | tr -d '\n')

PROFILE=$(powerprofilesctl get | tr -d '\n')

printf '{"battery_name": "%s", "profile": "%s"}\n' "$BAT_NAME" "$PROFILE"
