"""Volume. Urutan: PulseAudio D-Bus -> wpctl/pactl + watcher (PipeWire)."""
import re
import subprocess
import threading
import time

from .base import Module
from .util import log

PA_CORE = "org.PulseAudio.Core1"
PROPS = "org.freedesktop.DBus.Properties"


class AudioModule(Module):
    name = "audio"

    def __init__(self, ctx):
        super().__init__(ctx)
        self.vol = 0
        self.muted = False
        self._pa_props = None

    def defaults(self):
        return {"vol_pct": 0, "vol_desc": "0%", "vol_muted": False}

    def _push(self):
        self.publish(vol_pct=self.vol, vol_desc=f"{self.vol}%", vol_muted=self.muted)

    # ── start ────────────────────────────────────────────────────────────────

    def start(self):
        import dbus

        bus = self.ctx.session_bus
        try:
            pa = bus.get_object("org.PulseAudio1", "/org/pulseaudio/core1")
            core = dbus.Interface(pa, PA_CORE)
            core.ListenForSignal(PA_CORE + ".Device.VolumeUpdated", [])
            core.ListenForSignal(PA_CORE + ".Device.MuteUpdated", [])
            core.ListenForSignal(PA_CORE + ".FallbackSinkUpdated", [])

            bus.add_signal_receiver(
                self._on_volume,
                signal_name="VolumeUpdated",
                dbus_interface=PA_CORE + ".Device",
            )
            bus.add_signal_receiver(
                self._on_mute,
                signal_name="MuteUpdated",
                dbus_interface=PA_CORE + ".Device",
            )
            self._pa_props = dbus.Interface(pa, PROPS)
            self._read_pa()
            log(self.name, "PulseAudio D-Bus subscribed")
        except Exception as e:
            log(self.name, f"D-Bus tidak tersedia ({e}), pakai wpctl/pactl")
            threading.Thread(target=self._watch, daemon=True).start()

    # ── PulseAudio D-Bus ─────────────────────────────────────────────────────

    def _read_pa(self):
        import dbus

        try:
            sink_path = str(self._pa_props.Get(PA_CORE, "FallbackSink"))
            sink = self.ctx.session_bus.get_object("org.PulseAudio1", sink_path)
            p = dbus.Interface(sink, PROPS).GetAll(PA_CORE + ".Device")
            volumes = list(p.get("Volume", [65536]))
            self.vol = int(sum(volumes) / len(volumes) * 100 / 65536)
            self.muted = bool(p.get("Mute", False))
            self._push()
        except Exception as e:
            log(self.name, f"read volume error: {e}")

    def _on_volume(self, volumes):
        self.vol = int(sum(volumes) / len(volumes) * 100 / 65536)
        self._push()

    def _on_mute(self, muted):
        self.muted = bool(muted)
        self._push()

    # ── PipeWire: baca via CLI ───────────────────────────────────────────────

    @staticmethod
    def _run(*args) -> str:
        try:
            return subprocess.run(
                args, capture_output=True, text=True, timeout=3
            ).stdout
        except Exception:
            return ""

    def _read_cli(self) -> bool:
        # wpctl (WirePlumber): "Volume: 0.76" atau "Volume: 0.76 [MUTED]"
        out = self._run("wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@")
        m = re.search(r"(\d+(?:\.\d+)?)", out)
        if m:
            self.vol = round(float(m.group(1)) * 100)
            self.muted = "MUTED" in out
            self._push()
            return True

        # fallback: pactl (butuh pipewire-pulse)
        out = self._run("pactl", "get-sink-volume", "@DEFAULT_SINK@")
        m = re.search(r"(\d+)%", out)
        if m:
            self.vol = int(m.group(1))
            self.muted = "yes" in self._run("pactl", "get-sink-mute", "@DEFAULT_SINK@")
            self._push()
            return True

        log(self.name, "gagal membaca volume (wpctl dan pactl tidak menjawab)")
        return False

    # ── PipeWire: watcher ────────────────────────────────────────────────────

    def _watch(self):
        self._read_cli()
        if self._watch_pactl():
            return
        log(self.name, "pactl subscribe tidak tersedia, polling tiap 1 detik")
        while True:
            time.sleep(1)
            self._read_cli()

    def _watch_pactl(self) -> bool:
        """True kalau jalan sampai berhenti sendiri; False kalau pactl tidak bisa dipakai."""
        try:
            proc = subprocess.Popen(
                ["pactl", "subscribe"],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
            )
        except OSError:
            return False

        got_event = False
        for line in proc.stdout:
            if "sink" not in line and "server" not in line:
                continue
            if "change" not in line and "new" not in line:
                continue
            got_event = True
            self._read_cli()
        proc.wait()
        # kalau berhenti tanpa pernah ada event, anggap koneksi gagal -> polling
        return got_event
