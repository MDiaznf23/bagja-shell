#!/bin/bash

# Generate rofi image
magick ~/.config/m3-colors/current_wallpaper -resize 800x -quality 100 ~/.config/m3-colors/current-rofi.jpg &

kill -SIGUSR1 $(pidof kitty) 2>/dev/null

# Tambahkan ini di wallpaper generator script setelah generate custom.lua
nvim --headless -c "lua require('base46').compile()" -c "qa"

SCHEME=$(ls -t ~/.config/m3-colors/output/*.json | head -1)
python3 -c "
import json
data = json.load(open('$SCHEME'))
out = dict(data['colors'])
out['mode'] = data['mode']
print(json.dumps(out, indent=2))
" > ~/.config/quickshell/colors/colors.json

# ── GTK theme ────────────────────────────────────────────────────────────────
MODE=$(python3 -c "import json; print(json.load(open('$SCHEME'))['mode'])")
export M3_MODE="$MODE"

# Apply gsettings
gsettings set org.gnome.desktop.interface gtk-theme "FlatColor"

if [ "$MODE" = "dark" ]; then
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    gsettings set org.gnome.desktop.interface icon-theme "Tela-dark"
else
    gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
    gsettings set org.gnome.desktop.interface icon-theme "Tela"
fi

if [ "$MODE" = "dark" ]; then
    gsettings set org.gnome.desktop.interface color-scheme "default"
    sleep 0.1
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
else
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    sleep 0.1
    gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
fi

# Force GTK refresh (same-mode different color scheme)
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
sleep 0.1
gsettings set org.gnome.desktop.interface gtk-theme "FlatColor"

echo "[gtk] Applied: FlatColor | Tela-${MODE} | prefer-${MODE}"

# ── Dolphin color reload ──────────────────────────────────────────────────────
pkill -x dolphin 2>/dev/null || true
echo "[kde] Dolphin killed — New color will be applied"
