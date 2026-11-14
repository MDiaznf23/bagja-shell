#!/bin/bash
# Hook m3wal: gambar & GIF -> awww, video -> awww (frame diam) + mpvpaper
# Env: M3_WALLPAPER[_STILL] (m3wal) atau WARNAZA_WALLPAPER[_STILL] (warnaza)

LOG="$HOME/.cache/m3-colors/awww-hook.log"
mkdir -p "$(dirname "$LOG")"

# Dipakai bersama oleh m3wal (M3_*) dan warnaza (WARNAZA_*)
FILE="${M3_WALLPAPER:-$WARNAZA_WALLPAPER}"
STILL="${M3_WALLPAPER_STILL:-${WARNAZA_WALLPAPER_STILL:-$FILE}}"

# Matikan mpvpaper sampai benar-benar mati (SIGTERM dulu, SIGKILL kalau bandel).
# Kalau tidak, layer video lama tetap menutupi wallpaper gambar baru.
stop_video() {
  pkill -x mpvpaper 2>/dev/null || return 0
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    pgrep -x mpvpaper >/dev/null || return 0
    sleep 0.1
  done
  pkill -9 -x mpvpaper 2>/dev/null
  sleep 0.2
}

# Pastikan awww-daemon hidup
if ! awww query >/dev/null 2>&1; then
  setsid awww-daemon >>"$LOG" 2>&1 < /dev/null &
  sleep 0.7
fi

set_awww() {   # $1 = file yang ditampilkan awww
  awww img "$1" \
    --transition-type grow \
    --transition-pos center \
    --transition-duration 1.5 \
    --transition-fps 60 >>"$LOG" 2>&1
}

stop_video

case "${FILE,,}" in
  # GIF: kirim file ASLI ke awww supaya tetap beranimasi
  *.gif)
    set_awww "$FILE"
    ;;

  # Video: transisi dengan frame diam, lalu mpvpaper setelah transisi selesai
  *.mp4|*.mkv|*.webm|*.mov|*.m4v)
    set_awww "$STILL"
    (
      sleep 1.6
      exec setsid mpvpaper -o "no-audio loop hwdec=auto" '*' "$FILE" \
        >>"$LOG" 2>&1 < /dev/null
    ) &
    disown
    ;;

  # Gambar biasa
  *)
    set_awww "$FILE"
    ;;
esac
