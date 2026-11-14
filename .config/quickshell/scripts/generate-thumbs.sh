#!/bin/bash
WALLDIR="$HOME/Pictures/Wallpapers"
THUMBDIR="/tmp/wallpaper-thumbs"
mkdir -p "$THUMBDIR"

# nullglob: pola tanpa file tidak jadi string literal; nocaseglob: .MP4/.JPG ikut terbaca
shopt -s nullglob nocaseglob

for img in "$WALLDIR"/*.{jpg,jpeg,png,webp,gif,mp4,mkv,webm,mov,m4v}; do
  [ -f "$img" ] || continue
  thumb="$THUMBDIR/$(basename "$img" | sed 's/\.[^.]*$//').jpg"

  if [ -f "$thumb" ]; then
    echo "$thumb|$img"
    continue
  fi

  ext="${img##*.}"
  case "${ext,,}" in
    mp4|mkv|webm|mov|m4v)
      # Video: ambil satu keyframe (cepat, tanpa decode seluruh video),
      # di detik ke-2 supaya bukan frame hitam/fade-in.
      # Kalau video lebih pendek dari 2 detik, pakai frame pertama.
      vf="scale=130:90:force_original_aspect_ratio=increase,crop=130:90"
      ffmpeg -nostdin -loglevel error -y -skip_frame nokey -ss 2 -i "$img" \
        -frames:v 1 -an -sn -vf "$vf" -q:v 3 "$thumb" 2>/dev/null \
      || ffmpeg -nostdin -loglevel error -y -i "$img" \
        -frames:v 1 -an -sn -vf "$vf" -q:v 3 "$thumb" 2>/dev/null
      ;;
    *)
      src="$img"
      if [[ "${ext,,}" == "gif" ]]; then
        src="${img}[0]"
      fi

      convert \
        -define jpeg:size=260x180 \
        -define png:size=260x180 \
        "$src" \
        -thumbnail 130x90^ \
        -gravity center \
        -extent 130x90 \
        -quality 80 \
        "$thumb" 2>/dev/null
      ;;
  esac

  if [ -s "$thumb" ]; then
    echo "$thumb|$img"
  else
    rm -f "$thumb"   # jangan simpan thumbnail kosong/gagal
  fi
done
