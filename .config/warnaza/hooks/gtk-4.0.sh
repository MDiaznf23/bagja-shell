# ~/.config/warnaza/warnaza-post.sh
if [ "$WARNAZA_MODE" = "dark" ]; then
  cp ~/.cache/warnaza/gtk4-dark.css ~/.config/gtk-4.0/colors.css
else
  cp ~/.cache/warnaza/gtk4-light.css ~/.config/gtk-4.0/colors.css
fi
