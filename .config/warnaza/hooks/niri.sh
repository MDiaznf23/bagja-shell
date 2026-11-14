#!/bin/bash
# Deliver the generated niri colors. niri live-reloads included files,
# so no reload command is needed (unlike hyprland.sh).

SOURCE=~/.cache/warnaza/colors_niri.kdl
OUTPUT_DIR=~/.config/niri
OUTPUT="$OUTPUT_DIR/colors_niri.kdl"

[ -f "$SOURCE" ] || exit 0
mkdir -p "$OUTPUT_DIR"

# Write to a temp file first, then move it into place atomically
TMPFILE=$(mktemp "$OUTPUT_DIR/.colors_niri.tmp.XXXXXX")
cat "$SOURCE" > "$TMPFILE"
mv -f "$TMPFILE" "$OUTPUT"

echo "[niri] Rewritten atomically: $OUTPUT"
