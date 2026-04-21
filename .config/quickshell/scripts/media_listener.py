#!/usr/bin/env python3
"""
media_listener.py — MPRIS2 D-Bus media watcher
Drop-in replacement for media_listener.sh

Usage:
    python media_listener.py --list            # list active players as JSON
    python media_listener.py --watch           # watch any player (auto-select)
    python media_listener.py --watch spotify   # watch specific player
"""

import sys
import os
import json
import hashlib
import subprocess
import argparse

import dbus
import dbus.mainloop.glib
from gi.repository import GLib

MPRIS_PREFIX = "org.mpris.MediaPlayer2."
MPRIS_PATH = "/org/mpris/MediaPlayer2"
IFACE_PLAYER = "org.mpris.MediaPlayer2.Player"
IFACE_PROPS = "org.freedesktop.DBus.Properties"
IFACE_DBUS = "org.freedesktop.DBus"
DEFAULT_COVER = os.path.expanduser("~/.config/quickshell/assets/default-cover.jpg")
POSITION_INTERVAL_MS = 1000  # poll position every 1 second


# ---------------------------------------------------------------------------
# Cover art
# ---------------------------------------------------------------------------


def get_cover(art_url: str, file_path: str) -> str:
    # 1. artUrl langsung (file://)
    clean_url = art_url.replace("file://", "") if art_url else ""
    if clean_url and os.path.isfile(clean_url):
        return clean_url

    # 2. File musik ada?
    clean_file = file_path.replace("file://", "") if file_path else ""
    if not clean_file or not os.path.isfile(clean_file):
        return DEFAULT_COVER

    # 3. Cover di direktori yang sama
    music_dir = os.path.dirname(clean_file)
    for name in ("cover.jpg", "folder.jpg"):
        candidate = os.path.join(music_dir, name)
        if os.path.isfile(candidate):
            return candidate
    for f in os.listdir(music_dir):
        if f.lower().endswith(".png"):
            return os.path.join(music_dir, f)

    # 4. Embedded cover via ffmpeg (cache di /tmp)
    cache_key = hashlib.md5(clean_file.encode()).hexdigest()
    cover_cache = f"/tmp/mpd_cover_{cache_key}.jpg"
    if os.path.isfile(cover_cache):
        return cover_cache
    try:
        result = subprocess.run(
            [
                "ffmpeg",
                "-i",
                clean_file,
                "-an",
                "-vcodec",
                "copy",
                cover_cache,
                "-y",
                "-loglevel",
                "quiet",
            ],
            timeout=5,
        )
        if result.returncode == 0 and os.path.getsize(cover_cache) > 0:
            return cover_cache
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass

    return DEFAULT_COVER


# ---------------------------------------------------------------------------
# Build output dict
# ---------------------------------------------------------------------------


def build_info(player_name: str, props_iface) -> dict:
    try:
        metadata = props_iface.Get(IFACE_PLAYER, "Metadata")
        status = str(props_iface.Get(IFACE_PLAYER, "PlaybackStatus"))
        position = int(props_iface.Get(IFACE_PLAYER, "Position"))
    except dbus.DBusException:
        return no_media_info()

    title = str(metadata.get("xesam:title", ""))
    artist = ", ".join(str(a) for a in metadata.get("xesam:artist", []))
    art_url = str(metadata.get("mpris:artUrl", ""))
    file_path = str(metadata.get("xesam:url", ""))
    length = int(metadata.get("mpris:length", 0))

    cover = get_cover(art_url, file_path)

    return {
        "player": player_name.replace(MPRIS_PREFIX, ""),
        "status": status,
        "title": title,
        "artist": artist,
        "cover": cover,
        "position": position,
        "length": length,
    }


def no_media_info() -> dict:
    return {
        "title": "No Media",
        "artist": "Offline",
        "status": "Stopped",
        "player": "",
        "cover": "",
        "position": 0,
        "length": 0,
    }


def emit(info: dict):
    print(json.dumps(info, ensure_ascii=False), flush=True)


# ---------------------------------------------------------------------------
# --list mode
# ---------------------------------------------------------------------------


def cmd_list(bus: dbus.SessionBus):
    names = bus.list_names()
    result = []
    for name in sorted(names):
        if not name.startswith(MPRIS_PREFIX):
            continue
        try:
            obj = bus.get_object(name, MPRIS_PATH)
            props = dbus.Interface(obj, IFACE_PROPS)
            status = str(props.Get(IFACE_PLAYER, "PlaybackStatus"))
        except dbus.DBusException:
            status = "Stopped"
        result.append(
            {
                "player": name.replace(MPRIS_PREFIX, ""),
                "status": status,
            }
        )
    print(json.dumps(result, ensure_ascii=False))


# ---------------------------------------------------------------------------
# --watch mode
# ---------------------------------------------------------------------------


def cmd_watch(bus: dbus.SessionBus, selected: str | None):
    loop = GLib.MainLoop()

    # Resolve full bus name
    def resolve_name(sel: str | None) -> str | None:
        names = bus.list_names()
        players = [n for n in names if n.startswith(MPRIS_PREFIX)]
        if not players:
            return None
        if sel is None:
            return players[0]
        # exact or prefix match
        full = MPRIS_PREFIX + sel
        for p in players:
            if p == full or p.startswith(full):
                return p
        return None

    # State
    state = {"bus_name": None, "props": None, "position_timer": None}

    def connect_player(bus_name: str):
        if state["bus_name"] == bus_name:
            return
        disconnect_player()
        try:
            obj = bus.get_object(bus_name, MPRIS_PATH)
            props = dbus.Interface(obj, IFACE_PROPS)
        except dbus.DBusException:
            return

        state["bus_name"] = bus_name
        state["props"] = props

        # Emit initial state
        emit(build_info(bus_name, props))

        # Subscribe PropertiesChanged for metadata/status changes
        bus.add_signal_receiver(
            on_props_changed,
            signal_name="PropertiesChanged",
            dbus_interface=IFACE_PROPS,
            bus_name=bus_name,
            path=MPRIS_PATH,
        )

        # Start position polling
        if state["position_timer"]:
            GLib.source_remove(state["position_timer"])
        state["position_timer"] = GLib.timeout_add(
            POSITION_INTERVAL_MS, on_position_tick
        )

    def disconnect_player():
        if state["bus_name"]:
            try:
                bus.remove_signal_receiver(
                    on_props_changed,
                    signal_name="PropertiesChanged",
                    dbus_interface=IFACE_PROPS,
                    bus_name=state["bus_name"],
                    path=MPRIS_PATH,
                )
            except Exception:
                pass
        state["bus_name"] = None
        state["props"] = None

    def on_props_changed(iface, changed, invalidated):
        if state["props"] is None:
            return
        # Only emit if metadata or status changed (skip Volume, Rate, etc.)
        if "Metadata" in changed or "PlaybackStatus" in changed:
            emit(build_info(state["bus_name"], state["props"]))

    def on_position_tick() -> bool:
        if state["props"] is None:
            return True  # keep timer alive, will reconnect later
        try:
            pos = int(state["props"].Get(IFACE_PLAYER, "Position"))
            status = str(state["props"].Get(IFACE_PLAYER, "PlaybackStatus"))
        except dbus.DBusException:
            return True
        if status == "Playing":
            # Emit lightweight position-only update
            info = build_info(state["bus_name"], state["props"])
            emit(info)
        return True  # repeat

    def on_name_owner_changed(name, old_owner, new_owner):
        if not name.startswith(MPRIS_PREFIX):
            return
        short = name.replace(MPRIS_PREFIX, "")

        if new_owner:
            # Player appeared
            if (
                selected is None
                or short == selected
                or name.startswith(MPRIS_PREFIX + selected)
            ):
                connect_player(name)
        else:
            # Player disappeared
            if name == state["bus_name"]:
                disconnect_player()
                emit(no_media_info())
                # Try to fall back to another player if --watch with no specific selection
                if selected is None:
                    fallback = resolve_name(None)
                    if fallback:
                        connect_player(fallback)

    # Watch for players appearing/disappearing
    bus.add_signal_receiver(
        on_name_owner_changed,
        signal_name="NameOwnerChanged",
        dbus_interface=IFACE_DBUS,
        path="/org/freedesktop/DBus",
    )

    # Connect to initial player
    initial = resolve_name(selected)
    if initial:
        connect_player(initial)
    else:
        emit(no_media_info())

    try:
        loop.run()
    except KeyboardInterrupt:
        pass


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------


def main():
    parser = argparse.ArgumentParser(description="MPRIS2 media watcher")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--list", action="store_true", help="List active players as JSON"
    )
    group.add_argument(
        "--watch",
        metavar="PLAYER",
        nargs="?",
        const="",
        help="Watch a player (optional name, e.g. spotify)",
    )
    args = parser.parse_args()

    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SessionBus()

    if args.list:
        cmd_list(bus)
    else:
        selected = args.watch if args.watch else None
        cmd_watch(bus, selected)


if __name__ == "__main__":
    main()
