#!/usr/bin/env bash


set -uo pipefail

echo "== Versi Hyprland =="
hyprctl version | head -3
echo

echo "== Metode yang tersedia di hl.dsp.window.* =="
hyprctl repl 'local t={} for k,v in pairs(hl.dsp.window) do table.insert(t,k) end table.sort(t) return table.concat(t, ", ")'
echo "   (jika 'resize' tidak muncul di daftar ini, moveactive/resizewindowpixel"
echo "    mungkin berada di sub-namespace lain, atau 'move' menangani keduanya)"
echo

ADDR=$(hyprctl activewindow -j 2>/dev/null | python3 -c 'import json,sys
try:
    print(json.load(sys.stdin)["address"])
except Exception:
    print("")' )

if [ -z "$ADDR" ]; then
    echo "Tidak ada jendela aktif yang terdeteksi. Buka/fokuskan jendela floating lalu jalankan lagi."
    exit 1
fi

echo "== Jendela aktif: $ADDR =="
echo

echo "== Menguji pergeseran ke (100, 100) dengan sintaks yang digunakan hypr_ipc.py =="
OUT=$(hyprctl dispatch "hl.dsp.window.move({ window = \"address:$ADDR\", x = 100, y = 100, relative = false })" 2>&1)
echo "$OUT"
if echo "$OUT" | grep -qi "error"; then
    echo
    echo "-> Gagal. Coba variasi berikut secara manual dan lihat mana yang tidak error:"
    echo "   hyprctl dispatch 'hl.dsp.window.move({ window = \"address:$ADDR\", coords = { 100, 100 }, mode = \"exact\" })'"
    echo "   hyprctl dispatch 'hl.dsp.window.move({ window = \"address:$ADDR\", coords = {x=100, y=100} })'"
    echo "   hyprctl dispatch 'hl.dsp.window.move({ window = \"address:$ADDR\", position = {100, 100} })'"
else
    echo "-> OK. Periksa secara visual apakah jendela telah berpindah ke (100,100)."
    echo "   Jika jendela TIDAK berpindah tapi tidak menghasilkan error (pernah terjadi"
    echo "   pada resizewindowpixel di versi lama), opsinya diterima namun diabaikan:"
    echo "   silakan coba variasi di atas juga."
fi
echo

echo "== Menguji pengubahan ukuran (resize) ke 800x600 dengan sintaks hypr_ipc.py =="
OUT=$(hyprctl dispatch "hl.dsp.window.resize({ window = \"address:$ADDR\", x = 800, y = 600, relative = false })" 2>&1)
echo "$OUT"
if echo "$OUT" | grep -qi "error"; then
    echo
    echo "-> Gagal. Coba variasi berikut secara manual dan lihat mana yang tidak error:"
    echo "   hyprctl dispatch 'hl.dsp.window.resize({ window = \"address:$ADDR\", size = { 800, 600 }, mode = \"exact\" })'"
    echo "   hyprctl dispatch 'hl.dsp.window.move({ window = \"address:$ADDR\", size = {800,600} })'"
else
    echo "-> OK. Periksa secara visual apakah ukuran jendela sekarang menjadi 800x600."
fi

echo
echo "== Setelah mengonfirmasi nama yang benar, edit HANYA dua fungsi ini"
echo "   di hypr_ipc.py: move_window_exact_lua() dan resize_window_exact_lua()"
