#!/bin/bash
# Switch to another theme via symlink swap:
#   ~/.config/quickshell -> ~/.local/share/quickshell-themes/<name>
#   ~/.config/hypr/active-ricing.lua -> ~/.config/hypr/<name>.lua
# Usage: theme_switch.sh <name>

set -uo pipefail

NAME="${1:?theme name is required}"

STATE_DIR="$HOME/.cache/quickshell"
STATE_FILE="$STATE_DIR/current-theme"

THEMES_DIR="$HOME/.local/share/quickshell-themes"
THEME_SRC="$THEMES_DIR/$NAME"
QS_LINK="$HOME/.config/quickshell"

HYPR_DIR="$HOME/.config/hypr"
HYPR_SRC="$HYPR_DIR/$NAME.lua"           # per-theme, written by theme_install.sh
HYPR_LINK="$HYPR_DIR/active-ricing.lua"  # fixed name, this is what hyprland.lua sources

NIRI_DIR="$HOME/.config/niri"
NIRI_SRC="$NIRI_DIR/$NAME.kdl"           # per-theme, written by theme_install.sh
NIRI_LINK="$NIRI_DIR/active-ricing.kdl"  # fixed name, this is what niri's config.kdl includes

mkdir -p "$STATE_DIR"

if [ ! -d "$THEME_SRC" ]; then
  echo "ERROR: theme not installed yet, install it first"
  exit 1
fi

# 1. Kill the running quickshell (default) instance
pkill -f "^qs$" >/dev/null 2>&1 || true
sleep 0.3

# 2. Point the hyprland symlink at this theme's config (if any), then reload
if [ -f "$HYPR_SRC" ]; then
  ln -sfn "$HYPR_SRC" "$HYPR_LINK"
  [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && { hyprctl reload >/dev/null 2>&1 || true; }
fi

# 2b. Same for niri: repoint the include symlink, then force a config reload
#     (niri also live-reloads on file changes, but a repointed symlink may not trigger it)
if [ -f "$NIRI_SRC" ]; then
  ln -sfn "$NIRI_SRC" "$NIRI_LINK"
  [ -n "${NIRI_SOCKET:-}" ] && { niri msg action load-config-file >/dev/null 2>&1 || true; }
fi

# 2c. Bawa warna terbaru ke theme tujuan.
#     Post script (m3wal/warnaza) menulis ke ~/.config/quickshell/colors/colors.json,
#     yaitu file di dalam theme yang SEDANG aktif. Tiap theme punya colors.json
#     sendiri, jadi theme tujuan masih berisi warna terakhir saat ia dipakai dulu.
#     Salin colors.json dari theme yang sedang aktif (isinya paling baru) sebelum
#     symlink dipindah.
OLD_COLORS="$QS_LINK/colors/colors.json"
if [ -f "$OLD_COLORS" ] && [ "$(readlink -f "$QS_LINK")" != "$(readlink -f "$THEME_SRC")" ]; then
  mkdir -p "$THEME_SRC/colors"
  cp -f "$OLD_COLORS" "$THEME_SRC/colors/colors.json"
fi

# 3. Point ~/.config/quickshell at this theme.
#    If that path is still a real folder (not a symlink), remove it first
#    so ln -sfn can replace it, instead of nesting inside it.
if [ -e "$QS_LINK" ] && [ ! -L "$QS_LINK" ]; then
  rm -rf "$QS_LINK"
fi
ln -sfn "$THEME_SRC" "$QS_LINK"

echo "$NAME" > "$STATE_FILE"

# 4. Launch a new instance (default, no -c) as a detached process
setsid qs >/dev/null 2>&1 &
disown

echo "SWITCHED"
