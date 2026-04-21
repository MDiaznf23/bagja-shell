#!/bin/bash
# Hook: kdeglobals switcher based on warnaza mode

CACHE_DIR="$HOME/.cache/warnaza"
KDEGLOBALS="$HOME/.config/kdeglobals"

if [ "$WARNAZA_MODE" = "light" ]; then
    cp "$CACHE_DIR/kdeglobals-light" "$KDEGLOBALS"
else
    cp "$CACHE_DIR/kdeglobals-dark" "$KDEGLOBALS"
fi

# Force Dolphin reload
pkill dolphin 2>/dev/null

echo "[kde] Applied: kdeglobals-${WARNAZA_MODE}"
