#!/bin/bash

get_workspaces() {
    local active_ws=$(hyprctl activeworkspace -j | jq -r '.id')
    
    # Combine workspaces and clients data
    jq -c -n \
        --argjson workspaces "$(hyprctl workspaces -j)" \
        --argjson clients "$(hyprctl clients -j)" \
        --argjson active "$active_ws" '
        $workspaces | map(
            . as $ws | 
            {
                id: .id,
                name: .name,
                focused: (.id == $active),
                windows: .windows,
                apps: ($clients | map(select(.workspace.id == $ws.id)) | map({class, title}))
            }
        ) | sort_by(.id)
    '
}

get_workspaces

if [ -S "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" ]; then
    socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | \
        grep --line-buffered -E "workspace|window" | while read -r line; do
        get_workspaces
    done
fi
