#!/bin/bash
WALLDIR="$HOME/Pictures/Wallpapers"
THUMBDIR="/tmp/wallpaper-thumbs"
mkdir -p "$THUMBDIR"

for img in "$WALLDIR"/*.{jpg,jpeg,png,webp,gif}; do
  [ -f "$img" ] || continue
  thumb="$THUMBDIR/$(basename "$img" | sed 's/\.[^.]*$//').jpg"

  if [ -f "$thumb" ]; then
    echo "$thumb|$img"
    continue
  fi

  src="$img"
  ext="${img##*.}"
  if [[ "${ext,,}" == "gif" ]]; then
    src="${img}[0]"
  fi

  convert \
    -define jpeg:size=260x180 \
    -define png:size=260x180 \
    "$src" \
    -thumbnail 130x90^ \
    -gravity center \
    -extent 130x90 \
    -quality 80 \
    "$thumb" 2>/dev/null

  if [ -s "$thumb" ]; then
    echo "$thumb|$img"
  fi
done
