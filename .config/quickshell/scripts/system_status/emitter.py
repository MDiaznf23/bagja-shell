"""Menggabungkan output semua modul jadi satu JSON datar, lalu print kalau berubah."""
import json
import threading


class Emitter:
    def __init__(self):
        self._data: dict = {}
        self._last: str | None = None
        self._lock = threading.Lock()
        self._enabled = False  # ditahan sampai semua modul selesai init

    def register(self, defaults: dict) -> None:
        """Isi nilai awal supaya JSON selalu lengkap, bahkan kalau satu modul gagal."""
        self._data.update(defaults)

    def update(self, fields: dict) -> None:
        with self._lock:
            self._data.update(fields)
            self._flush()

    def enable(self) -> None:
        with self._lock:
            self._enabled = True
            self._flush()

    def _flush(self) -> None:
        if not self._enabled:
            return
        out = json.dumps(self._data, ensure_ascii=False, sort_keys=True)
        if out != self._last:
            self._last = out
            print(out, flush=True)
