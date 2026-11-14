#!/bin/bash
ENGINE=$1

case "$ENGINE" in
  m3wal|warnaza) ;;
  *) echo "[set_engine] engine not known: '$ENGINE'" >&2; exit 1 ;;
esac

WALL=""
newest=0
for d in "$HOME/.config/m3-colors" "$HOME/.config/warnaza"; do
  link="$d/current_wallpaper"
  [ -L "$link" ] || continue
  target=$(readlink -f "$link")
  [ -f "$target" ] || continue
  t=$(stat -c %Y "$link")          
  if [ "$t" -gt "$newest" ]; then
    newest=$t
    WALL=$target
  fi
done

if [ -z "$WALL" ]; then
  WALL=$(awww query 2>/dev/null | awk -F': ' '{print $NF}' | head -1)
fi

if [ ! -f "$WALL" ]; then
  echo "[set_engine] wallpaper not found" >&2
  exit 1
fi

exec "$ENGINE" "$WALL"
