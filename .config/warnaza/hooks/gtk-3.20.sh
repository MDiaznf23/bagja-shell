#!/bin/bash
templates="$HOME/.cache/warnaza/"
gtk320_dir="$HOME/.local/share/themes/FlatColor/gtk-3.20"
cp "$templates/gtk.3.20-$WARNAZA_MODE" "$gtk320_dir/gtk.css"
