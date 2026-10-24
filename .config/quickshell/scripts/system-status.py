#!/usr/bin/env python3
"""
system-status.py — entry point tipis.
Logika sebenarnya ada di package `system_status/` (satu modul per fitur).
Path ini sengaja tidak berubah, jadi StateGlobals.qml tidak perlu diubah di sisi Process.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from system_status.app import run  # noqa: E402

if __name__ == "__main__":
    run()
