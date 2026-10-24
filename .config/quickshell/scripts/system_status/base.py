"""Kelas dasar semua modul."""
from dataclasses import dataclass

from .emitter import Emitter


@dataclass
class Context:
    system_bus: object
    session_bus: object
    emitter: Emitter


class Module:
    name = "module"

    def __init__(self, ctx: Context):
        self.ctx = ctx

    def defaults(self) -> dict:
        """Nilai awal untuk key JSON milik modul ini."""
        return {}

    def start(self) -> None:
        """Baca state awal + pasang listener."""
        raise NotImplementedError

    def publish(self, **fields) -> None:
        self.ctx.emitter.update(fields)
