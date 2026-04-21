#!/bin/bash
SESSION_NAME="$1"
SESSION_ICON="${2:-󰘚}"

SESSIONS_FILE="$HOME/.config/quickshell/sessions.json"
WS=$(hyprctl activeworkspace -j | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])")
GAPS_IN=$(hyprctl getoption general:gaps_in | grep "custom type" | awk '{print $3}')
GAPS_OUT=$(hyprctl getoption general:gaps_out | grep "custom type" | awk '{print $3}')
LAYOUT=$(hyprctl getoption general:layout | grep "str:" | awk '{print $2}')

hyprctl clients -j | python3 -c "
import json, sys, os

clients = json.load(sys.stdin)
EXCLUDE = ['quickshell', 'waybar', 'rofi', 'dunst']
ws_clients = [c for c in clients if c['workspace']['id'] == $WS and c['class'] not in EXCLUDE]
ws_clients.sort(key=lambda c: c['at'][0])

apps = []
for i, c in enumerate(ws_clients):
    pid = c['pid']
    try:
        cmd = open(f'/proc/{pid}/cmdline').read().replace('\x00', ' ').strip()
        exec_cmd = os.path.basename(cmd.split()[0])
    except:
        exec_cmd = c['class']
    apps.append({
        'exec': exec_cmd,
        'class': c['class'],
        'workspace': $WS,
        'delay': i * 200
    })

if ws_clients:
    gaps_in = $GAPS_IN
    gaps_out = $GAPS_OUT
    n = len(ws_clients)
    raw_screen = max(c['at'][0] + c['size'][0] for c in ws_clients) + gaps_out
    usable = raw_screen - (gaps_out * 2) - (gaps_in * (n + 1))
    master_ratio = ws_clients[0]['size'][0] / usable
    mfact = round(master_ratio - 0.502, 2)
else:
    mfact = 0.0

sessions_file = '$SESSIONS_FILE'
session_name = '$SESSION_NAME'
session_icon = '$SESSION_ICON'

try:
    with open(sessions_file, 'r', encoding='utf-8') as f:
        current = json.load(f)
    if not isinstance(current, list):
        current = []
except:
    current = []

new_session = {
    'id': session_name.lower().replace(' ', '-'),
    'name': session_name,
    'icon': session_icon,
    'layout': '$LAYOUT',
    'mfact': mfact,
    'apps': apps
}
current.append(new_session)

with open(sessions_file, 'w', encoding='utf-8') as f:
    json.dump(current, f, indent=2, ensure_ascii=False)
"
