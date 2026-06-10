#!/bin/bash

SOURCE=~/.cache/warnaza/colors_hyprland.lua
OUTPUT=~/.config/hypr/colors_hyprland.lua
TMPFILE=$(mktemp ~/.config/hypr/.colors_hyprland.tmp.XXXXXX)

# Tulis ke tmp dulu
cat "$SOURCE" > "$TMPFILE"

mv -f "$TMPFILE" "$OUTPUT"

echo "[hyprland] Rewritten atomically: $OUTPUT"

hyprctl reload &
