#!/bin/bash

SOURCE=~/.cache/warnaza/colors_hyprland
OUTPUT=~/.config/hypr/colors_hyprland.conf
TMPFILE=$(mktemp ~/.config/hypr/.colors_hyprland.tmp.XXXXXX)

# Tulis ke tmp dulu
cat "$SOURCE" > "$TMPFILE"

mv -f "$TMPFILE" "$OUTPUT"

echo "[hyprland] Rewritten atomically: $OUTPUT"

hyprctl reload &
