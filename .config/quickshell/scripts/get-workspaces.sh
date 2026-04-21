#!/bin/bash

get_workspaces() {
    local active_ws
    active_ws=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id') || return

    hyprctl -j workspaces 2>/dev/null | jq -c \
        --argjson clients "$(hyprctl -j clients 2>/dev/null)" \
        --argjson active "$active_ws" '
        map(. as $ws | {
            id: .id,
            name: .name,
            focused: (.id == $active),
            windows: .windows,
            apps: ($clients | map(select(.workspace.id == $ws.id)) | map({class, title, address}))
        }) | sort_by(.id)
    '
}

get_workspaces

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
[ -S "$SOCKET" ] || exit 0

socat -u UNIX-CONNECT:"$SOCKET" - 2>/dev/null | \
    grep --line-buffered -E "^(workspace|activewindow|openwindow|closewindow|movewindow)" | \
    while IFS= read -r _line; do
        # debounce: tunggu 50ms, drain event yang datang bersamaan
        read -r -t 0.05 _drain 2>/dev/null || true
        get_workspaces
    done
