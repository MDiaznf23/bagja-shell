# ~/.config/warnaza/warnaza-post.sh

magick ~/.config/warnaza/current_wallpaper -resize 800x -quality 100 ~/.config/warnaza/current-rofi.jpg &

kill -SIGUSR1 $(pidof kitty) 2>/dev/null

# neovim reload
nvim --headless -c "lua require('base46').compile()" -c "qa"

SCHEME=$(ls -t ~/.config/warnaza/output/*.json | head -1)

python3 -c "
import json
data = json.load(open('$SCHEME'))

out = {}
for name, entry in data['colors'].items():
    out[name]              = entry['hex']
    out[f'{name}_rgb']     = entry['rgb']
    out[f'{name}_hypr']    = entry['hypr']

out['mode'] = data['mode']
print(json.dumps(out, indent=2))
" > ~/.config/quickshell/colors/colors.json

# ── GTK theme ────────────────────────────────────────────────────────────────

SCHEME=$(ls -t ~/.config/warnaza/output/*.json | head -1)
MODE=$(python3 -c "import json; print(json.load(open('$SCHEME'))['mode'])")
export WARNAZA_MODE="$MODE"

# Apply gsettings
gsettings set org.gnome.desktop.interface gtk-theme "FlatColor"
if [ "$MODE" = "dark" ]; then
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    gsettings set org.gnome.desktop.interface icon-theme "Tela-dark"
else
    gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
    gsettings set org.gnome.desktop.interface icon-theme "Tela"
fi

# Force GTK refresh (same-mode different color scheme)
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
sleep 0.1
gsettings set org.gnome.desktop.interface gtk-theme "FlatColor"

if [ "$MODE" = "dark" ]; then
    gsettings set org.gnome.desktop.interface color-scheme "default"
    sleep 0.1
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
else
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    sleep 0.1
    gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
fi 

echo "[gtk] Applied: FlatColor | Tela-${MODE} | prefer-${MODE}"

# ── Dolphin color reload ──────────────────────────────────────────────────────
pkill -x dolphin 2>/dev/null || true
echo "[kde] Dolphin killed — New color will be applied"
