#!/usr/bin/env python3

import subprocess
import json
import sys
import signal

MODE = sys.argv[1] if len(sys.argv) > 1 else "sink"

process = None


def cleanup(signum, frame):
    global process
    if process:
        process.terminate()
        try:
            process.wait(timeout=2)
        except subprocess.TimeoutExpired:
            process.kill()
    sys.exit(0)


signal.signal(signal.SIGTERM, cleanup)
signal.signal(signal.SIGINT, cleanup)


def get_data():
    try:
        cmd = f"pactl -f json list {MODE}s"
        result = subprocess.run(cmd.split(), capture_output=True, text=True, timeout=5)
        return get_devices_logic(result.stdout)
    except:
        return []


def get_devices_logic(json_str):
    try:
        data = json.loads(json_str)
    except:
        return []

    processed_data = []

    try:
        def_cmd = f"pactl get-default-{MODE}"
        default_dev = subprocess.run(
            def_cmd.split(), capture_output=True, text=True, timeout=5
        ).stdout.strip()
    except:
        default_dev = ""

    for item in data:
        vol_avg = 0
        if "volume" in item:
            try:
                vals = [
                    int(v["value_percent"].strip("%"))
                    for k, v in item["volume"].items()
                ]
                vol_avg = sum(vals) // len(vals) if vals else 0
            except:
                vol_avg = 0

        processed_data.append(
            {
                "id": item.get("index"),
                "name": item.get("description"),
                "name_short": (item.get("description") or "")[:25],
                "volume": vol_avg,
                "is_active": item.get("name") == default_dev,
                "type": MODE,
            }
        )
    return processed_data


def main():
    global process

    print(json.dumps(get_data()), flush=True)

    process = subprocess.Popen(
        ["pactl", "subscribe"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    )

    while True:
        line = process.stdout.readline()
        if not line:
            break
        if MODE in line or "server" in line:
            print(json.dumps(get_data()), flush=True)


if __name__ == "__main__":
    main()
