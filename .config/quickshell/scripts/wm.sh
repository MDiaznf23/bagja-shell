#!/bin/bash
# Compositor adapter for bagja-shell. One entry point, one command set,
# works on Hyprland and niri. Detection is by environment variables set by
# the compositor itself.
#
# Usage: wm.sh <command> [args]
#   name                          print: hyprland | niri | unknown
#   workspaces-stream             print workspace JSON once, then on every change
#   active-title-stream           print focused window title once, then on change
#   active-workspace              print {"id": N} for the focused workspace
#   focus-workspace <id>
#   move-window <address> <ws_id>
#   close-window <address>
#   logout
#
# Workspace JSON contract (one array per line, sorted by id):
#   [{id, name, focused, windows, apps:[{class,title,address}]}]
# On niri, "id" is the workspace index on the focused monitor.

set -u

detect() {
  if [ -n "${NIRI_SOCKET:-}" ]; then echo niri
  elif [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then echo hyprland
  else echo unknown
  fi
}

WM="$(detect)"

format_title() {
  local title="$1"
  if [ -z "$title" ]; then
    echo "Desktop"
  elif [ ${#title} -gt 25 ]; then
    echo "${title:0:25}..."
  else
    echo "$title"
  fi
}

# ─── Hyprland backend ─────────────────────────────────────────

hypr_socket() {
  if [ -d "${XDG_RUNTIME_DIR:-}/hypr" ]; then
    echo "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
  else
    echo "/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
  fi
}

hypr_workspaces() {
  local active_ws
  active_ws=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id') || return
  hyprctl -j workspaces 2>/dev/null | jq -c \
    --argjson clients "$(hyprctl -j clients 2>/dev/null)" \
    --argjson active "$active_ws" '
    map(. as $ws | {
        id: .id,
        name: .name,
        focused: (.id == $active),
        windows: .windows,
        apps: ($clients | map(select(.workspace.id == $ws.id)) | map({class, title, address}))
    }) | sort_by(.id)
  '
}

hypr_workspaces_stream() {
  hypr_workspaces
  local sock; sock="$(hypr_socket)"
  [ -S "$sock" ] || exit 0
  socat -u UNIX-CONNECT:"$sock" - 2>/dev/null | \
    grep --line-buffered -E "^(workspace|activewindow|openwindow|closewindow|movewindow)" | \
    while IFS= read -r _line; do
      # debounce: wait 50ms, drain events that arrive together
      read -r -t 0.05 _drain 2>/dev/null || true
      hypr_workspaces
    done
}

hypr_active_title() {
  hyprctl activewindow -j 2>/dev/null | jq -r '.title // empty'
}

hypr_active_title_stream() {
  format_title "$(hypr_active_title)"
  local sock; sock="$(hypr_socket)"
  [ -S "$sock" ] || { echo "Error: Socket not found"; exit 1; }
  socat -u UNIX-CONNECT:"$sock" - | while read -r line; do
    if [[ "$line" == activewindow* ]]; then
      format_title "$(hypr_active_title)"
    fi
  done
}

# ─── niri backend ─────────────────────────────────────────────

# Only the focused monitor's workspaces are shown. A workspace is listed if
# it is named, has windows, or is the active one (hides niri's trailing
# empty workspace until you actually go there).
niri_workspaces() {
  local ws win
  ws=$(niri msg --json workspaces 2>/dev/null) || return
  win=$(niri msg --json windows 2>/dev/null) || win='[]'
  [ -n "$win" ] || win='[]'
  jq -c --argjson win "$win" '
    (([.[] | select(.is_focused)][0] // .[0]).output) as $out
    | [ .[] | select(.output == $out) ]
    | map(. as $w
        | ([ $win[] | select(.workspace_id == $w.id) ]) as $apps
        | {
            id: .idx,
            name: (.name // (.idx | tostring)),
            focused: .is_active,
            windows: ($apps | length),
            named: (.name != null),
            apps: ($apps | map({class: (.app_id // ""), title: (.title // ""), address: (.id | tostring)}))
          })
    | map(select(.named or .windows > 0 or .focused))
    | map(del(.named))
    | sort_by(.id)
  ' <<<"$ws"
}

# Events that can change workspace/window membership or focus.
# WindowLayoutsChanged is deliberately excluded: it fires constantly while
# scrolling and does not affect this data.
NIRI_EVENTS='^\{"(WorkspacesChanged|WorkspaceActivated|WindowsChanged|WindowOpenedOrChanged|WindowClosed|WindowFocusChanged)"'

niri_workspaces_stream() {
  niri_workspaces
  niri msg --json event-stream 2>/dev/null | \
    grep --line-buffered -E "$NIRI_EVENTS" | \
    while IFS= read -r _line; do
      read -r -t 0.05 _drain 2>/dev/null || true
      niri_workspaces
    done
}

niri_active_title() {
  niri msg --json focused-window 2>/dev/null | jq -r '.title // empty'
}

niri_active_title_stream() {
  format_title "$(niri_active_title)"
  niri msg --json event-stream 2>/dev/null | \
    grep --line-buffered -E '^\{"(WindowFocusChanged|WindowOpenedOrChanged|WindowClosed)"' | \
    while IFS= read -r _line; do
      read -r -t 0.05 _drain 2>/dev/null || true
      format_title "$(niri_active_title)"
    done
}

niri_active_workspace() {
  niri msg --json workspaces 2>/dev/null | \
    jq -c '[.[] | select(.is_focused)][0] | {id: (.idx // 1)}'
}

# ─── Dispatch ─────────────────────────────────────────────────

cmd="${1:-}"
shift || true

case "$cmd" in
  name) echo "$WM" ;;

  workspaces-stream)
    case "$WM" in
      hyprland) hypr_workspaces_stream ;;
      niri)     niri_workspaces_stream ;;
      *)        echo "[]" ;;
    esac ;;

  active-title-stream)
    case "$WM" in
      hyprland) hypr_active_title_stream ;;
      niri)     niri_active_title_stream ;;
      *)        echo "Desktop" ;;
    esac ;;

  active-workspace)
    case "$WM" in
      hyprland) hyprctl activeworkspace -j ;;
      niri)     niri_active_workspace ;;
      *)        echo '{"id":1}' ;;
    esac ;;

  focus-workspace)
    id="${1:?workspace id required}"
    case "$WM" in
      hyprland) hyprctl dispatch "hl.dsp.focus({ workspace = \"$id\" })" ;;
      niri)     niri msg action focus-workspace "$id" ;;
    esac ;;

  move-window)
    addr="${1:?window address required}"; ws="${2:?workspace id required}"
    case "$WM" in
      hyprland)
        hyprctl dispatch "hl.dsp.window.move({ workspace = $ws, silent = true, window = \"address:$addr\" })" ;;
      niri)
        # Preferred: move the given window directly. Fallback: focus it first.
        niri msg action move-window-to-workspace --window-id "$addr" --focus false "$ws" 2>/dev/null \
          || { niri msg action focus-window --id "$addr" && niri msg action move-window-to-workspace "$ws"; } ;;
    esac ;;

  close-window)
    addr="${1:?window address required}"
    case "$WM" in
      hyprland) hyprctl dispatch "hl.dsp.window.close({ window = \"address:$addr\" })" ;;
      niri)     niri msg action close-window --id "$addr" ;;
    esac ;;

  logout)
    case "$WM" in
      hyprland) command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()' ;;
      niri)     niri msg action quit --skip-confirmation ;;
    esac ;;

  *)
    echo "Usage: $0 {name|workspaces-stream|active-title-stream|active-workspace|focus-workspace|move-window|close-window|logout}" >&2
    exit 1 ;;
esac
