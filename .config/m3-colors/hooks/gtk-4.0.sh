#!/usr/bin/env bash
# ~/.config/m3-colors/hooks/gtk-4.0.sh

MODE="${M3_MODE}"

if [ "$MODE" = "dark" ]; then
    cp ~/.cache/m3-colors/gtk4-dark.css ~/.config/gtk-4.0/colors.css
else
    cp ~/.cache/m3-colors/gtk4-light.css ~/.config/gtk-4.0/colors.css
fi
