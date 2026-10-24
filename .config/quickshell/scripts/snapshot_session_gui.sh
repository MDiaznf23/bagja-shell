#!/bin/bash
SESSION_NAME="$1"
SESSION_ICON="${2:-󰘚}"

SESSIONS_FILE="$HOME/.config/quickshell/config/sessions.json"

WS=$(hyprctl activeworkspace -j | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])")

GAPS_IN=$(hyprctl -j getoption general.gaps_in | python3 -c "
import json, sys
d = json.load(sys.stdin)
custom = d.get('custom', '').strip()
if custom:
    print(custom.split()[0])
else:
    print(d.get('int', 0))
")

GAPS_OUT=$(hyprctl -j getoption general.gaps_out | python3 -c "
import json, sys
d = json.load(sys.stdin)
custom = d.get('custom', '').strip()
if custom:
    print(custom.split()[0])
else:
    print(d.get('int', 0))
")

LAYOUT=$(hyprctl -j getoption general.layout | python3 -c "import json,sys; print(json.load(sys.stdin)['str'])")

hyprctl clients -j | python3 -c "
import json, sys, os, glob, shlex, configparser

clients = json.load(sys.stdin)
EXCLUDE = ['quickshell', 'waybar', 'rofi', 'dunst']
ws_clients = [c for c in clients if c['workspace']['id'] == $WS and c['class'] not in EXCLUDE]
ws_clients.sort(key=lambda c: c['at'][0])

DESKTOP_DIRS = [
    os.path.expanduser('~/.local/share/applications'),
    '/usr/share/applications',
    '/usr/local/share/applications',
    '/var/lib/flatpak/exports/share/applications',
    os.path.expanduser('~/.local/share/flatpak/exports/share/applications'),
]

FIELD_CODES = {'%f', '%F', '%u', '%U', '%d', '%D', '%n', '%N', '%i', '%c', '%k', '%v', '%m'}

def clean_exec(exec_line):
    if not exec_line:
        return None
    try:
        parts = shlex.split(exec_line)
    except ValueError:
        parts = exec_line.split()
    parts = [p for p in parts if p not in FIELD_CODES]
    return ' '.join(parts) if parts else None

desktop_index = {}
for d in DESKTOP_DIRS:
    if not os.path.isdir(d):
        continue
    for f in glob.glob(os.path.join(d, '**', '*.desktop'), recursive=True):
        try:
            cp = configparser.ConfigParser(interpolation=None, strict=False)
            cp.read(f, encoding='utf-8')
            if 'Desktop Entry' not in cp:
                continue
            entry = cp['Desktop Entry']
            cleaned = clean_exec(entry.get('Exec', ''))
            if not cleaned:
                continue
            wmclass = entry.get('StartupWMClass', '').strip()
            if wmclass:
                desktop_index[wmclass.lower()] = cleaned
            # fallback key: nama file .desktop itu sendiri (misal openplc-editor.desktop)
            base = os.path.splitext(os.path.basename(f))[0].lower()
            desktop_index.setdefault(base, cleaned)
            # fallback key lain: Name= di dalam .desktop (kadang class = nama app, bukan wmclass)
            name = entry.get('Name', '').strip()
            if name:
                desktop_index.setdefault(name.lower(), cleaned)
        except Exception:
            continue

def resolve_exec(c):
    klass = c['class']
    # 1) cocokkan lewat StartupWMClass / nama .desktop (paling akurat)
    hit = desktop_index.get(klass.lower())
    if hit:
        return hit
    # 2) fallback: baca /proc/pid/cmdline seperti sebelumnya
    try:
        cmd = open(f'/proc/{c[\"pid\"]}/cmdline').read().replace('\x00', ' ').strip()
        if cmd:
            return os.path.basename(cmd.split()[0])
    except Exception:
        pass
    # 3) fallback terakhir: pakai class apa adanya
    return klass

apps = []
for i, c in enumerate(ws_clients):
    exec_cmd = resolve_exec(c)
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
