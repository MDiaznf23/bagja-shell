#!/bin/bash
# Kept for compatibility: QML still calls this path. Logic lives in wm.sh.
exec bash "$(dirname "$0")/wm.sh" active-title-stream
