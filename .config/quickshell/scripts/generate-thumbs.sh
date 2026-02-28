#!/bin/bash
WALLDIR="$HOME/Pictures/Wallpapers"
THUMBDIR="/tmp/wallpaper-thumbs"
mkdir -p "$THUMBDIR"

for img in "$WALLDIR"/*.{jpg,jpeg,png,webp}; do
  [ -f "$img" ] || continue
  thumb="$THUMBDIR/$(basename "$img").jpg"
  [ -f "$thumb" ] && continue
  convert "$img" -thumbnail 130x90^ -gravity center -extent 130x90 "$thumb" 2>/dev/null
done
