#!/usr/bin/env bash
# Launcher manual untuk Infinite Desktop.
# infinite_desktop_core.py sudah mendeteksi keyboard & mouse sendiri (via evdev),
# jadi skrip ini cukup meneruskan SPEED saja.
#
# Penggunaan: ~/scripts/infinite-desktop.sh [speed]   (default 1.6)
set -euo pipefail

SPEED="${1:-1.6}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cegah dua instans berjalan bersamaan (autostart + manual).
if pgrep -f "infinite_desktop_core.py" >/dev/null 2>&1; then
    echo "⚠️  infinite_desktop_core.py sudah berjalan. Hentikan dulu dengan:"
    echo "    pkill -f infinite_desktop_core.py"
    exit 1
fi

# Tunggu sebentar agar Hyprland siap jika dipanggil saat login.
sleep "${INFINITE_DESKTOP_DELAY:-0}"

exec python3 "$SCRIPT_DIR/infinite_desktop_core.py" "$SPEED"
