#!/usr/bin/env python3
"""
wifi_listener.py — Event-driven WiFi list via NetworkManager D-Bus
Replaces scan_wifi.sh polling. Emits JSON list setiap ada perubahan AP.

Usage:
    python3 -u wifi_listener.py
"""

import sys
import json
import dbus
import dbus.mainloop.glib
from gi.repository import GLib

NM_BUS = "org.freedesktop.NetworkManager"
NM_PATH = "/org/freedesktop/NetworkManager"
NM_IFACE = "org.freedesktop.NetworkManager"
DEV_IFACE = "org.freedesktop.NetworkManager.Device"
WIFI_IFACE = "org.freedesktop.NetworkManager.Device.Wireless"
AP_IFACE = "org.freedesktop.NetworkManager.AccessPoint"
PROPS_IFACE = "org.freedesktop.DBus.Properties"


def log(msg):
    print(f"[wifi-listener] {msg}", file=sys.stderr, flush=True)


def emit(data):
    print(json.dumps(data, ensure_ascii=False), flush=True)


class WifiListener:
    def __init__(self, bus: dbus.SystemBus):
        self.bus = bus
        self.wifi_dev_path = None
        self.wifi_dev_proxy = None
        self._ap_signal_handlers = {}  # ap_path -> signal match

        self._find_wifi_device()
        if self.wifi_dev_path:
            self._subscribe_device_signals()
            self._request_scan()
        else:
            log("No WiFi device found")
            emit([])

    # ── Device discovery ──────────────────────────────────────────────────────

    def _find_wifi_device(self):
        try:
            nm = self.bus.get_object(NM_BUS, NM_PATH)
            devices = nm.GetDevices(dbus_interface=NM_IFACE)
            for dev_path in devices:
                dev = self.bus.get_object(NM_BUS, dev_path)
                props = dbus.Interface(dev, PROPS_IFACE)
                dev_type = int(props.Get(DEV_IFACE, "DeviceType"))
                if dev_type == 2:  # NM_DEVICE_TYPE_WIFI
                    self.wifi_dev_path = str(dev_path)
                    self.wifi_dev_proxy = dev
                    log(f"WiFi device: {dev_path}")
                    return
        except Exception as e:
            log(f"Error finding WiFi device: {e}")

    # ── Subscribe signals ─────────────────────────────────────────────────────

    def _subscribe_device_signals(self):
        # AP list changes
        self.bus.add_signal_receiver(
            self._on_ap_added,
            signal_name="AccessPointAdded",
            dbus_interface=WIFI_IFACE,
            path=self.wifi_dev_path,
        )
        self.bus.add_signal_receiver(
            self._on_ap_removed,
            signal_name="AccessPointRemoved",
            dbus_interface=WIFI_IFACE,
            path=self.wifi_dev_path,
        )
        # Scan selesai → LastScan berubah
        self.bus.add_signal_receiver(
            self._on_dev_props_changed,
            signal_name="PropertiesChanged",
            dbus_interface=PROPS_IFACE,
            path=self.wifi_dev_path,
        )
        # Connected AP berubah (connect/disconnect)
        self.bus.add_signal_receiver(
            self._on_dev_props_changed,
            signal_name="PropertiesChanged",
            dbus_interface=PROPS_IFACE,
            bus_name=NM_BUS,
            path=self.wifi_dev_path,
        )
        log("Device signals subscribed")

    def _subscribe_ap_strength(self, ap_path: str):
        """Subscribe ke PropertiesChanged tiap AP untuk update signal strength."""
        if ap_path in self._ap_signal_handlers:
            return
        handler = self.bus.add_signal_receiver(
            lambda iface, changed, inv, p=ap_path: self._on_ap_props_changed(
                p, changed
            ),
            signal_name="PropertiesChanged",
            dbus_interface=PROPS_IFACE,
            path=ap_path,
        )
        self._ap_signal_handlers[ap_path] = handler

    def _unsubscribe_ap_strength(self, ap_path: str):
        handler = self._ap_signal_handlers.pop(ap_path, None)
        if handler:
            try:
                self.bus.remove_signal_receiver(
                    handler,
                    signal_name="PropertiesChanged",
                    dbus_interface=PROPS_IFACE,
                    path=ap_path,
                )
            except Exception:
                pass

    # ── Signal callbacks ──────────────────────────────────────────────────────

    def _on_ap_added(self, ap_path):
        self._subscribe_ap_strength(str(ap_path))
        self._emit_list()

    def _on_ap_removed(self, ap_path):
        self._unsubscribe_ap_strength(str(ap_path))
        self._emit_list()

    def _on_dev_props_changed(self, iface, changed, invalidated):
        if "LastScan" in changed or "ActiveAccessPoint" in changed:
            self._emit_list()

    def _on_ap_props_changed(self, ap_path, changed):
        if "Strength" in changed:
            self._emit_list()

    # ── Scan request ──────────────────────────────────────────────────────────

    def _request_scan(self):
        try:
            wifi_iface = dbus.Interface(self.wifi_dev_proxy, WIFI_IFACE)
            wifi_iface.RequestScan({})
            log("Scan requested")
        except Exception as e:
            log(f"RequestScan error (biasanya ok): {e}")
            # Tetap emit dari cache
            self._emit_list()

    # ── Build & emit list ─────────────────────────────────────────────────────

    def _get_active_ap_path(self) -> str:
        try:
            props = dbus.Interface(self.wifi_dev_proxy, PROPS_IFACE)
            return str(props.Get(WIFI_IFACE, "ActiveAccessPoint"))
        except Exception:
            return "/"

    def _get_ap_data(self, ap_path: str, active_ap_path: str) -> dict | None:
        try:
            ap = self.bus.get_object(NM_BUS, ap_path)
            props = dbus.Interface(ap, PROPS_IFACE)
            p = props.GetAll(AP_IFACE)

            ssid_bytes = p.get("Ssid", b"")
            try:
                ssid = bytes(ssid_bytes).decode("utf-8", errors="replace").strip()
            except Exception:
                ssid = ""

            if not ssid:
                return None

            signal = int(p.get("Strength", 0))
            wpa = int(p.get("WpaFlags", 0))
            rsn = int(p.get("RsnFlags", 0))
            flags = int(p.get("Flags", 0))
            secured = wpa > 0 or rsn > 0 or (flags & 0x1) > 0
            security = (
                "WPA2"
                if rsn > 0
                else ("WPA" if wpa > 0 else ("WEP" if flags & 0x1 else ""))
            )
            connected = ap_path == active_ap_path

            return {
                "ssid": ssid,
                "signal": signal,
                "security": security,
                "secured": secured,
                "connected": connected,
                "sig_icon": _sig_icon(signal),
                "sec_icon": "󰌾" if secured else "",
            }
        except Exception as e:
            log(f"AP data error {ap_path}: {e}")
            return None

    def _emit_list(self):
        try:
            wifi_iface = dbus.Interface(self.wifi_dev_proxy, WIFI_IFACE)
            ap_paths = wifi_iface.GetAccessPoints()
        except Exception as e:
            log(f"GetAccessPoints error: {e}")
            emit([])
            return

        active_ap = self._get_active_ap_path()

        # Subscribe strength untuk semua AP yang ada
        for ap_path in ap_paths:
            self._subscribe_ap_strength(str(ap_path))

        networks = []
        seen_ssids = set()
        for ap_path in ap_paths:
            data = self._get_ap_data(str(ap_path), active_ap)
            if data and data["ssid"] not in seen_ssids:
                seen_ssids.add(data["ssid"])
                networks.append(data)

        # Sort: connected first, then by signal desc
        networks.sort(key=lambda x: (not x["connected"], -x["signal"]))
        emit(networks)


def _sig_icon(signal: int) -> str:
    if signal >= 75:
        return "󰤨"
    if signal >= 50:
        return "󰤥"
    if signal >= 25:
        return "󰤢"
    return "󰤯"


# ── Entry point ───────────────────────────────────────────────────────────────


def main():
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SystemBus()
    _listener = WifiListener(bus)
    log("Listening...")
    loop = GLib.MainLoop()
    try:
        loop.run()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
