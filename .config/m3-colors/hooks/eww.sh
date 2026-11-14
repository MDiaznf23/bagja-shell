#!/bin/bash
eww_dir="$HOME/.config/eww"
cp "$eww_dir/eww-$M3_MODE.scss" "$eww_dir/eww.scss"

# Cek daemon dulu
eww ping &>/dev/null || eww daemon &
sleep 0.5
eww reload
