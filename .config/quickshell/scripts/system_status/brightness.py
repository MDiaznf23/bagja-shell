"""Brightness via inotify di /sys/class/backlight."""
from pathlib import Path

from .base import Module
from .util import log, watch_path


class BrightnessModule(Module):
    name = "brightness"

    def __init__(self, ctx):
        super().__init__(ctx)
        self.path = self._detect()

    def defaults(self):
        return {"bright_pct": 0, "bright_desc": "0%"}

    @staticmethod
    def _detect() -> Path | None:
        root = Path("/sys/class/backlight")
        if not root.is_dir():
            return None  # desktop tanpa backlight
        for p in root.iterdir():
            if (p / "brightness").exists():
                return p
        return None

    def _read(self):
        pct = 0
        try:
            cur = int((self.path / "brightness").read_text())
            mx = int((self.path / "max_brightness").read_text())
            pct = int(cur * 100 / mx) if mx > 0 else 0
        except (OSError, ValueError):
            pass
        self.publish(bright_pct=pct, bright_desc=f"{pct}%")

    def start(self):
        if not self.path:
            log(self.name, "backlight tidak ditemukan, dilewati")
            return
        self._read()
        try:
            watch_path(str(self.path), self._read)
            log(self.name, f"inotify: {self.path}")
        except Exception as e:
            log(self.name, f"inotify error: {e}")
