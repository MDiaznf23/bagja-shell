#!/bin/bash
# ~/.config/quickshell/scripts/xwindow-clickable.sh

format_title() {
    local title="$1"
    if [ -z "$title" ]; then
        echo "Desktop"
    else
        if [ ${#title} -gt 25 ]; then
            echo "${title:0:25}..."
        else
            echo "$title"
        fi
    fi
}

# Check socket (priority XDG_RUNTIME_DIR)
if [ -d "$XDG_RUNTIME_DIR/hypr" ]; then
    SOCKET_PATH="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
else
    SOCKET_PATH="/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
fi

# Check Socket
if [ ! -S "$SOCKET_PATH" ]; then
    echo "Error: Socket not found"
    exit 1
fi

# Get initial title
title=$(hyprctl activewindow -j 2>/dev/null | jq -r '.title // empty')
format_title "$title"

# Monitor active window changes
socat -u UNIX-CONNECT:"$SOCKET_PATH" - | while read -r line; do
    if [[ "$line" == activewindow* ]] || [[ "$line" == "activewindowv2"* ]]; then
        title=$(hyprctl activewindow -j 2>/dev/null | jq -r '.title // empty')
        format_title "$title"
    fi
done
