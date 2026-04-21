#!/bin/bash
templates="$HOME/.cache/warnaza/"
gtk3_dir="$HOME/.local/share/themes/FlatColor/gtk-3.0"
cp "$templates/gtk-$WARNAZA_MODE.css" "$gtk3_dir/gtk.css"
