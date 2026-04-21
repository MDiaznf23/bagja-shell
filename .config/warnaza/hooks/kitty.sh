#!/bin/bash
# Hook: kitty color switcher based on warnaza mode

CACHE_DIR="$HOME/.cache/warnaza"
KITTY_COLORS="$HOME/.config/kitty/colors.conf"

if [ "$WARNAZA_MODE" = "light" ]; then
    cp "$CACHE_DIR/kitty-colors-light.conf" "$KITTY_COLORS"
else
    cp "$CACHE_DIR/kitty-colors-dark.conf" "$KITTY_COLORS"
fi

# Reload kitty
kill -SIGUSR1 $(pgrep -a kitty | awk '{print $1}') 2>/dev/null

echo "[kitty] Applied: colors-${WARNAZA_MODE}.conf"
