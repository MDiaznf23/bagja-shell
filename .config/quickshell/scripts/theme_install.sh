#!/bin/bash

set -uo pipefail

NAME="${1:?theme name is required}"
REPO="${2:?repo url is required}"
BRANCH="${3:-main}"

STAGING_DIR="$HOME/.cache/quickshell/staging"
STAGING="$STAGING_DIR/$NAME"
THEMES_DIR="$HOME/.local/share/quickshell-themes"
DEST="$THEMES_DIR/$NAME"
DEST_NEW="${DEST}.new"
DEST_OLD="${DEST}.old"
HYPR_DIR="$HOME/.config/hypr"
HYPR_DEST="$HYPR_DIR/$NAME.lua"
STATE_FILE="$HOME/.cache/quickshell/current-theme"

mkdir -p "$STAGING_DIR" "$THEMES_DIR" "$HYPR_DIR"

# 1. Clone / update the full repo into staging (temporary, can be large & nested)
if [ -d "$STAGING/.git" ]; then
  if ! git -C "$STAGING" fetch origin "$BRANCH" --depth 1 >/dev/null 2>&1; then
    echo "ERROR: failed to fetch update"
    exit 1
  fi
  git -C "$STAGING" reset --hard "origin/$BRANCH" >/dev/null 2>&1
else
  rm -rf "$STAGING"
  if ! git clone --depth 1 --branch "$BRANCH" "$REPO" "$STAGING" >/dev/null 2>&1; then
    rm -rf "$STAGING"
    echo "ERROR: failed to clone repo"
    exit 1
  fi
fi

# 2. Find the quickshell folder inside the cloned repo (try a few common patterns)
QS_SRC=""
for candidate in ".config/quickshell" "quickshell" "."; do
  if [ -f "$STAGING/$candidate/shell.qml" ]; then
    QS_SRC="$STAGING/$candidate"
    break
  fi
done

if [ -z "$QS_SRC" ]; then
  echo "ERROR: shell.qml not found in repo (check folder structure)"
  exit 1
fi

# 3. Prepare the new content in a temporary folder first (DEST itself untouched so far)
rm -rf "$DEST_NEW"
cp -r "$QS_SRC" "$DEST_NEW"

# 4. Atomic swap: move the old one aside to .old, put the new one in place,
#    then remove the old one. The gap between the two "mv" calls is just
#    microseconds, far safer than rm-then-cp which can take a while.
if [ -d "$DEST" ]; then
  rm -rf "$DEST_OLD"
  mv "$DEST" "$DEST_OLD"
fi
mv "$DEST_NEW" "$DEST"
rm -rf "$DEST_OLD"

# 5. Find hyprland.lua (optional, not required)
HYPR_SRC=""
for candidate in ".config/hypr/hyprland.lua" "hypr/hyprland.lua"; do
  if [ -f "$STAGING/$candidate" ]; then
    HYPR_SRC="$STAGING/$candidate"
    break
  fi
done

if [ -n "$HYPR_SRC" ]; then
  cp "$HYPR_SRC" "$HYPR_DEST"
fi

# 6. Cursor theme (.icons/) - optional, safe for relative symlinks inside it
#    (cp -r does not dereference symlinks by default)
if [ -d "$STAGING/.icons" ]; then
  mkdir -p "$HOME/.icons"
  cp -r "$STAGING/.icons/." "$HOME/.icons/"
fi

# 7. Extra fonts (Fonts/) - optional, installed to the user's font directory
if [ -d "$STAGING/Fonts" ]; then
  mkdir -p "$HOME/.local/share/fonts"
  cp -r "$STAGING/Fonts/." "$HOME/.local/share/fonts/"
  fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1 || true
fi

# 8. If this theme is currently active (~/.config/quickshell symlink points
#    here), restart qs so the change takes effect without clicking Switch.
CURRENT="$(cat "$STATE_FILE" 2>/dev/null || true)"
if [ "$CURRENT" = "$NAME" ]; then
  pkill -f "^qs$" >/dev/null 2>&1 || true
  sleep 0.3
  setsid qs >/dev/null 2>&1 &
  disown
fi

echo "DONE"
