#!/bin/bash
# ~/.config/warnaza/warnaza-post.sh — versi cepat (aman untuk wallpaper video)

CFG="$HOME/.config/warnaza"
SCHEME=$(ls -t "$CFG"/output/*.json | head -1)

# Pakai gambar diam (frame video) kalau ada; jangan pernah kasih video ke magick
STILL="$CFG/current_wallpaper_still"
[ -e "$STILL" ] || STILL="$CFG/current_wallpaper"

# ── Satu kali baca JSON: tulis colors.json + ambil MODE ─────────────────────
MODE=$(python3 - "$SCHEME" "$HOME/.config/quickshell/colors/colors.json" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))

out = {}
for name, entry in data["colors"].items():
    out[name]          = entry["hex"]
    out[f"{name}_rgb"]  = entry["rgb"]
    out[f"{name}_hypr"] = entry["hypr"]
out["mode"] = data["mode"]

json.dump(out, open(sys.argv[2], "w"), indent=2)
print(data["mode"])
PY
)
export WARNAZA_MODE="$MODE"

# ── Gambar rofi (dari frame diam; [0] = frame pertama untuk GIF) ────────────
magick "${STILL}[0]" -resize 800x -quality 90 "$CFG/current-rofi.jpg" &

# ── GIF -> mp4 (dipakai komponen lain). Hanya dikonversi kalau sumbernya ────
#    berubah, bukan di setiap apply.
SRC=$(readlink -f "$CFG/current_wallpaper")
if file -bL "$SRC" | grep -q "GIF"; then
    STAMP="$SRC|$(stat -c '%Y|%s' "$SRC")"
    if [ ! -s "$CFG/current_wallpaper.mp4" ] || [ "$(cat "$CFG/current_wallpaper.mp4.src" 2>/dev/null)" != "$STAMP" ]; then
        ffmpeg -nostdin -loglevel error -y -i "$SRC" \
            -vf "fps=15,scale=1920:-2:flags=lanczos" \
            -c:v libx264 -pix_fmt yuv420p -an \
            "$CFG/current_wallpaper.mp4" && echo "$STAMP" > "$CFG/current_wallpaper.mp4.src"
    fi
fi

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
