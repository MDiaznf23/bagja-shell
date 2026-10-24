"""Merakit semua modul. Mau matikan fitur? Hapus dari MODULES."""
import sys

from .audio import AudioModule
from .base import Context
from .battery import BatteryModule
from .brightness import BrightnessModule
from .emitter import Emitter
from .network import NetworkModule
from .util import log

MODULES = [
    BatteryModule,
    NetworkModule,
    AudioModule,
    BrightnessModule,
]


def run():
    import dbus
    import dbus.mainloop.glib
    from gi.repository import GLib

    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    ctx = Context(dbus.SystemBus(), dbus.SessionBus(), Emitter())

    modules = [cls(ctx) for cls in MODULES]
    for m in modules:
        ctx.emitter.register(m.defaults())

    for m in modules:
        try:
            m.start()
        except Exception as e:  # satu modul gagal tidak mematikan yang lain
            log(m.name, f"gagal start: {e}")

    ctx.emitter.enable()  # emit pertama setelah semua state awal terbaca
    log("main", "aktif")

    try:
        GLib.MainLoop().run()
    except KeyboardInterrupt:
        print("\n[system-status] dihentikan.", file=sys.stderr)
