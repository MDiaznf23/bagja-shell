"""WiFi via NetworkManager D-Bus + sampling kecepatan jaringan."""
import threading
import time
from pathlib import Path

from .base import Module
from .util import format_speed, log

NM = "org.freedesktop.NetworkManager"
PROPS = "org.freedesktop.DBus.Properties"
SPEED_INTERVAL = 2.0  # detik antar sample


class NetworkModule(Module):
    name = "network"

    def __init__(self, ctx):
        super().__init__(ctx)
        self.iface = self._detect_wifi()
        self.connected = False
        self.rx_rate = 0.0
        self.tx_rate = 0.0

    def defaults(self):
        return {
            "wifi_connected": False,
            "wifi_powered": False,
            "wifi_signal": 0,
            "wifi_ssid": "",
            "wifi_security": "",
            "wifi_desc": "Disconnected",
        }

    # ── start ────────────────────────────────────────────────────────────────

    def start(self):
        try:
            self.ctx.system_bus.add_signal_receiver(
                self._on_changed,
                signal_name="PropertiesChanged",
                dbus_interface=PROPS,
                bus_name=NM,
            )
            log(self.name, "NetworkManager subscribed")
        except Exception as e:
            log(self.name, f"subscribe error: {e}")

        self._refresh()
        threading.Thread(target=self._speed_loop, daemon=True).start()

    # ── wifi ─────────────────────────────────────────────────────────────────

    @staticmethod
    def _detect_wifi() -> str:
        try:
            for iface in Path("/sys/class/net").iterdir():
                if (iface / "wireless").is_dir():
                    return iface.name
        except OSError:
            pass
        return ""

    def _refresh(self):
        import dbus

        bus = self.ctx.system_bus
        try:
            nm = bus.get_object(NM, "/org/freedesktop/NetworkManager")
            nm_props = dbus.Interface(nm, PROPS)

            powered = bool(nm_props.Get(NM, "WirelessEnabled"))

            # Status koneksi diambil dari device wifi itu sendiri (100 = activated),
            # BUKAN dari State global NM: state global bisa turun ke "site only"
            # (60) atau "local only" (50) kalau cek internet gagal, padahal wifi tetap tersambung.
            self.connected = False
            ssid, signal, security = "", 0, ""
            for dev_path in nm.GetDevices(dbus_interface=NM):
                dev_props = dbus.Interface(bus.get_object(NM, dev_path), PROPS)
                if int(dev_props.Get(NM + ".Device", "DeviceType")) != 2:
                    continue  # bukan wifi
                if int(dev_props.Get(NM + ".Device", "State")) != 100:
                    continue  # belum activated
                ap_path = str(dev_props.Get(NM + ".Device.Wireless", "ActiveAccessPoint"))
                if ap_path == "/":
                    continue
                ap = dbus.Interface(bus.get_object(NM, ap_path), PROPS)
                apn = NM + ".AccessPoint"
                ssid = bytes(ap.Get(apn, "Ssid")).decode("utf-8", errors="replace")
                signal = int(ap.Get(apn, "Strength"))
                flags = int(ap.Get(apn, "Flags"))
                wpa = int(ap.Get(apn, "WpaFlags"))
                rsn = int(ap.Get(apn, "RsnFlags"))
                if rsn > 0:
                    security = "WPA2"
                elif wpa > 0:
                    security = "WPA"
                elif flags & 0x1:
                    security = "WEP"
                else:
                    security = "Open"
                self.connected = True
                break

            self.publish(
                wifi_connected=self.connected,
                wifi_powered=powered,
                wifi_signal=signal,
                wifi_ssid=ssid,
                wifi_security=security,
                wifi_desc=self._desc(),
            )
        except Exception as e:
            log(self.name, f"wifi error: {e}")

    def _on_changed(self, iface, changed, invalidated):
        if "State" in changed or "ActiveAccessPoint" in changed or "Strength" in changed:
            self._refresh()

    # ── kecepatan ────────────────────────────────────────────────────────────

    def _desc(self) -> str:
        if not self.connected:
            return "Disconnected"
        return f"↓{format_speed(self.rx_rate)} ↑{format_speed(self.tx_rate)}"

    def _read_bytes(self) -> tuple[int, int]:
        if not self.iface:
            return 0, 0
        base = Path(f"/sys/class/net/{self.iface}/statistics")
        try:
            return (
                int((base / "rx_bytes").read_text()),
                int((base / "tx_bytes").read_text()),
            )
        except (OSError, ValueError):
            return 0, 0

    def _speed_loop(self):
        while True:
            time.sleep(SPEED_INTERVAL)
            rx1, tx1 = self._read_bytes()
            time.sleep(1.0)
            rx2, tx2 = self._read_bytes()
            self.rx_rate = rx2 - rx1
            self.tx_rate = tx2 - tx1
            self.publish(wifi_desc=self._desc())
