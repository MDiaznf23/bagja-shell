#!/bin/bash

case "$1" in
  list)
    cliphist list | while IFS=$'\t' read -r id text; do
      preview=$(echo "$text" | head -1 | cut -c1-60)
      echo "$id	$preview"
    done
    ;;
  decode)
    # $2 = id, $3 = full text
    printf "%s\t%s" "$2" "$3" | cliphist decode | wl-copy
    ;;
  delete)
    printf "%s\t%s" "$2" "$3" | cliphist delete
    ;;
  wipe)
    cliphist wipe
    wl-copy --clear
    pkill -f "wl-paste.*cliphist" 2>/dev/null
    nohup wl-paste --type text --watch cliphist store &>/dev/null &
    ;;
esac
