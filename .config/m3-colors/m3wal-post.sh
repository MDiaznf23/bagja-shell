#!/bin/bash
# m3wal-post.sh — versi cepat (aman untuk wallpaper video)

CFG="$HOME/.config/m3-colors"
SCHEME=$(ls -t "$CFG"/output/*.json | head -1)

STILL="$CFG/current_wallpaper_still"
[ -e "$STILL" ] || STILL="$CFG/current_wallpaper"

# ── Satu kali baca JSON: tulis colors.json + ambil MODE ─────────────────────
MODE=$(python3 - "$SCHEME" "$HOME/.config/quickshell/colors/colors.json" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
out = dict(data["colors"]); out["mode"] = data["mode"]
json.dump(out, open(sys.argv[2], "w"), indent=2)
print(data["mode"])
PY
)

# ── Rofi image (background, dari still → cepat) ─────────────────────────────
magick "$STILL" -resize 800x -quality 90 "$CFG/current-rofi.jpg" &

# ── Kitty ───────────────────────────────────────────────────────────────────
pids=$(pidof kitty) && kill -SIGUSR1 $pids 2>/dev/null

# ── Neovim base46 (background supaya tidak blocking) ────────────────────────
nvim --headless -c "lua require('base46').compile()" -c "qa" >/dev/null 2>&1 &

# ── GTK: gsettings dijalankan sekali saja ───────────────────────────────────
if [ "$MODE" = "dark" ]; then
    SCHEME_PREF="prefer-dark";  ICONS="Tela-dark"; OTHER="default"
else
    SCHEME_PREF="prefer-light"; ICONS="Tela";      OTHER="prefer-dark"
fi
gsettings set org.gnome.desktop.interface icon-theme "$ICONS"
# toggle sekali supaya GTK reload warna
gsettings set org.gnome.desktop.interface color-scheme "$OTHER"
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
gsettings set org.gnome.desktop.interface color-scheme "$SCHEME_PREF"
gsettings set org.gnome.desktop.interface gtk-theme "FlatColor"
echo "[gtk] Applied: FlatColor | $ICONS | $SCHEME_PREF"

# ── Dolphin ─────────────────────────────────────────────────────────────────
pkill -x dolphin 2>/dev/null || true
echo "[kde] Dolphin killed — warna baru diterapkan saat dibuka lagi"

wait
