#!/bin/bash
templates="$HOME/.cache/warnaza/"
gtkrc_dir="$HOME/.local/share/themes/FlatColor/gtk-2.0"
cp "$templates/gtkrc-$WARNAZA_MODE" "$gtkrc_dir/gtkrc"
