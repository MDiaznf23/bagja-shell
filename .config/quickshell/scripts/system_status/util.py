"""Helper bersama: logging, format kecepatan, inotify."""
import ctypes
import os
import select
import sys
import threading

IN_MODIFY = 0x00000002
IN_CLOSE_WRITE = 0x00000008

_libc = ctypes.CDLL("libc.so.6", use_errno=True)


def log(tag: str, msg: str) -> None:
    print(f"[system-status:{tag}] {msg}", file=sys.stderr, flush=True)


def format_speed(bps: float) -> str:
    if bps < 1024:
        return f"{int(bps)}B/s"
    if bps < 1048576:
        return f"{bps / 1024:.1f}K/s"
    return f"{bps / 1048576:.1f}M/s"


def watch_path(path: str, callback, mask: int = IN_MODIFY | IN_CLOSE_WRITE) -> None:
    """Jalankan callback() di thread daemon setiap ada event inotify pada path."""
    fd = _libc.inotify_init()
    if fd < 0:
        raise OSError(ctypes.get_errno(), "inotify_init gagal")
    wd = _libc.inotify_add_watch(fd, path.encode(), mask)
    if wd < 0:
        raise OSError(ctypes.get_errno(), f"inotify_add_watch gagal: {path}")

    def _loop():
        while True:
            select.select([fd], [], [])
            os.read(fd, 4096)  # buang event
            callback()

    threading.Thread(target=_loop, daemon=True).start()
