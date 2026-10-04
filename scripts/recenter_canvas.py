#!/usr/bin/env python3
"""
recenter_canvas.py
Memusatkan seluruh jendela floating di workspace aktif ke tengah layar monitor.
Jika ada jendela yang sedang aktif/fokus, jendela tersebut dijadikan titik pusat.
Jika tidak ada, seluruh kumpulan jendela floating dipusatkan berdasarkan titik tengahnya.

Penggunaan: python3 recenter_canvas.py
"""

import subprocess
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from hypr_ipc import hyprctl_json, move_window_exact_lua, batch_async


def get_monitor_center():
    monitors = hyprctl_json(["monitors"]) or []
    for m in monitors:
        if m.get("focused"):
            return m["x"] + m["width"] // 2, m["y"] + m["height"] // 2
    return 960, 540


def send_notification(title, message):
    try:
        subprocess.Popen(
            ["notify-send", "-t", "1200", "-a", "Infinite Desktop", title, message],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except Exception:
        pass


def main():
    ws = hyprctl_json(["activeworkspace"])
    if not ws:
        sys.exit(0)
    workspace_id = ws["id"]

    clients = hyprctl_json(["clients"]) or []
    floating = [
        w for w in clients
        if w.get("workspace", {}).get("id") == workspace_id and w.get("floating")
    ]

    if not floating:
        sys.exit(0)

    center_x, center_y = get_monitor_center()

    # Periksa apakah ada jendela aktif yang merupakan bagian dari floating di workspace ini
    focused = hyprctl_json(["activewindow"])
    target_window = None
    if focused and focused.get("floating") and focused.get("workspace", {}).get("id") == workspace_id:
        target_window = focused

    if target_window:
        tx = target_window["at"][0] + target_window["size"][0] // 2
        ty = target_window["at"][1] + target_window["size"][1] // 2
    else:
        # Hitung titik tengah dari bounding box seluruh jendela floating
        min_x = min(w["at"][0] for w in floating)
        max_x = max(w["at"][0] + w["size"][0] for w in floating)
        min_y = min(w["at"][1] for w in floating)
        max_y = max(w["at"][1] + w["size"][1] for w in floating)
        tx = (min_x + max_x) // 2
        ty = (min_y + max_y) // 2

    dx = center_x - tx
    dy = center_y - ty

    if dx == 0 and dy == 0:
        send_notification("🎯 Infinite Desktop", "Kanvas sudah berada di posisi tengah.")
        sys.exit(0)

    exprs = []
    for w in floating:
        nx = w["at"][0] + dx
        ny = w["at"][1] + dy
        exprs.append(move_window_exact_lua(int(nx), int(ny), w["address"]))

    batch_async(exprs)
    send_notification("🎯 Infinite Desktop", "Kanvas berhasil dipusatkan ke tengah layar.")


if __name__ == "__main__":
    main()
