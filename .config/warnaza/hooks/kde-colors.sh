#!/bin/bash
# Hook: kde colors switcher based on warnaza mode

CACHE_DIR="$HOME/.cache/warnaza"
DEST1="$HOME/.config/qt6ct/colors/material3.colors"
DEST2="$HOME/.local/share/color-schemes/Material3.colors"

if [ "$WARNAZA_MODE" = "light" ]; then
    SRC="$CACHE_DIR/kde-light.colors"
else
    SRC="$CACHE_DIR/kde-dark.colors"
fi

cp "$SRC" "$DEST1"
cp "$SRC" "$DEST2"

# Force Dolphin reload
pkill dolphin 2>/dev/null

echo "[kde] Applied: kde-colors-${WARNAZA_MODE} → qt6ct + color-schemes"
