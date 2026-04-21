#!/bin/bash
WALLDIR="$HOME/Pictures/Wallpapers"
THUMBDIR="/tmp/wallpaper-thumbs"
mkdir -p "$THUMBDIR"

for img in "$WALLDIR"/*.{jpg,jpeg,png,webp}; do
  [ -f "$img" ] || continue
  thumb="$THUMBDIR/$(basename "$img" | sed 's/\.[^.]*$//').jpg"
  [ -f "$thumb" ] && continue

  convert \
    -define jpeg:size=260x180 \
    -define png:size=260x180 \
    "$img" \
    -thumbnail 130x90^ \
    -gravity center \
    -extent 130x90 \
    -quality 80 \
    "$thumb" 2>/dev/null

  # Hanya echo kalau file hasil convert valid (bukan 0 byte)
  if [ -s "$thumb" ]; then
    echo "$thumb|$img"
  fi
done
