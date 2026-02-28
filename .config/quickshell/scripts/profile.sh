#!/bin/bash

# SETTINGS
IMAGE_URL="file:///home/$USER/.config/quickshell/assets/profile.jpg"

# Helper
get_wm() {
    if pgrep -x "i3" > /dev/null; then echo "i3";
    elif pgrep -x "bspwm" > /dev/null; then echo "bspwm";
    elif pgrep -x "awesome" > /dev/null; then echo "awesome";
    elif pgrep -x "dwm" > /dev/null; then echo "dwm";
    elif pgrep -x "hyprland" > /dev/null; then echo "hyprland";
    elif [ "$XDG_CURRENT_DESKTOP" ]; then echo "$XDG_CURRENT_DESKTOP";
    else echo "Unknown"; fi
}

# uptime short
get_uptime() {
    uptime -p | sed 's/up //' | sed 's/ hours/h/' | sed 's/ hour/h/' | sed 's/ minutes/m/' | sed 's/ minute/m/' | sed 's/,//'
}

case "$1" in
    json)
        wm_name=$(get_wm)
        up_time=$(get_uptime)
        
        echo "{\"username\": \"$USER\", \"wm\": \"$wm_name\", \"uptime\": \"$up_time\", \"image\": \"$IMAGE_URL\"}"
        ;;

    username) echo "$USER" ;;
    wm) get_wm ;;
    uptime) uptime -p | sed 's/up //' ;;
    uptime-short) get_uptime ;;
    image-url) echo "$IMAGE_URL" ;;
    
    *)
        echo "Usage: $0 {json|username|wm|uptime|image-url}"
        exit 1
        ;;
esac
