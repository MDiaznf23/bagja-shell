#!/bin/bash

set -uo pipefail

CATALOG_URL="${QS_THEME_CATALOG_URL:-https://raw.githubusercontent.com/MDiaznf23/quickshell-themes-catalog/main/catalog.json}"

CACHE_DIR="$HOME/.cache/quickshell"
CACHE_FILE="$CACHE_DIR/themes-catalog.json"

mkdir -p "$CACHE_DIR"

if curl -fsSL --max-time 8 "$CATALOG_URL" -o "$CACHE_FILE.tmp" 2>/dev/null; then
  if python3 -c "import json,sys; json.load(open('$CACHE_FILE.tmp'))" 2>/dev/null; then
    mv "$CACHE_FILE.tmp" "$CACHE_FILE"
    echo "OK"
  else
    rm -f "$CACHE_FILE.tmp"
    [ -f "$CACHE_FILE" ] && echo "STALE" || echo "FAIL"
  fi
else
  rm -f "$CACHE_FILE.tmp"
  [ -f "$CACHE_FILE" ] && echo "STALE" || echo "FAIL"
fi
