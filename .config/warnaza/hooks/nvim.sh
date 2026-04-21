#!/bin/bash
# Hook: nvim color switcher based on warnaza mode

CACHE_DIR="$HOME/.cache/warnaza"
NVIM_COLORS="$HOME/.config/nvim/lua/themes/material3.lua"

if [ "$WARNAZA_MODE" = "light" ]; then
    cp "$CACHE_DIR/colors-nvim-light.lua" "$NVIM_COLORS"
else
    cp "$CACHE_DIR/colors-nvim-dark.lua" "$NVIM_COLORS"
fi

echo "[nvim] Applied: colors-nvim-${WARNAZA_MODE}.lua"
