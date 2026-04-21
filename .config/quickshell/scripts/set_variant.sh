#!/bin/bash
VARIANT=$(echo "$1" | tr '[:upper:]' '[:lower:]')
CONFIG="$HOME/.config/m3-colors/m3-colors.conf"
sed -i "s/^variant = .*/variant = $VARIANT/" "$CONFIG"
WALLPAPER=$(awww query | awk -F': ' '{print $NF}' | head -1)
m3wal "$WALLPAPER"
