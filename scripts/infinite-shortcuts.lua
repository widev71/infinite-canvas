-- File ini berisi semua shortcut untuk plugin Hyprland Infinite Desktop.
-- Semua shortcut menggunakan 3 kombinasi tombol modifier (SUPER + 2 tombol) agar 100% bebas bentrok.
-- Silakan ubah shortcut di bawah jika ingin menyesuaikan dengan preferensi Anda.

local hl = require("hyprland")
local mainMod = "SUPER"

-- ========== WORKSPACE (SUPER + CTRL + SHIFT) ==========
hl.bind(mainMod .. " + CTRL + SHIFT + Z", hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + X", hl.dsp.focus({ workspace = "+1" }))

-- ========== LEMPAR JENDELA KE WORKSPACE LAIN (SUPER + ALT + SHIFT) ==========
hl.bind(mainMod .. " + ALT + SHIFT + Z", hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + ALT + SHIFT + X", hl.dsp.window.move({ workspace = "+1" }))

-- ========== TOGGLE LAYOUT & RECENTER (SUPER + CTRL + ALT) ==========
hl.bind(mainMod .. " + CTRL + ALT + D", hl.dsp.exec_cmd("python3 ~/scripts/floating_tile_toggle.py"))
hl.bind(mainMod .. " + CTRL + ALT + 0", hl.dsp.exec_cmd("python3 ~/scripts/recenter_canvas.py"))

-- ========== NAVIGASI JENDELA DI KANVAS (SUPER + CTRL + ALT) ==========
hl.bind(mainMod .. " + CTRL + ALT + left",  hl.dsp.exec_cmd("python3 ~/scripts/navigate_windows.py left"))
hl.bind(mainMod .. " + CTRL + ALT + right", hl.dsp.exec_cmd("python3 ~/scripts/navigate_windows.py right"))
hl.bind(mainMod .. " + CTRL + ALT + up",    hl.dsp.exec_cmd("python3 ~/scripts/navigate_windows.py up"))
hl.bind(mainMod .. " + CTRL + ALT + down",  hl.dsp.exec_cmd("python3 ~/scripts/navigate_windows.py down"))

-- ========== PINDAH JENDELA FLOATING (SUPER + CTRL + SHIFT) ==========
hl.bind(mainMod .. " + CTRL + SHIFT + left",  hl.dsp.exec_cmd("python3 ~/scripts/move_window.py left"),  { repeating = true })
hl.bind(mainMod .. " + CTRL + SHIFT + right", hl.dsp.exec_cmd("python3 ~/scripts/move_window.py right"), { repeating = true })
hl.bind(mainMod .. " + CTRL + SHIFT + up",    hl.dsp.exec_cmd("python3 ~/scripts/move_window.py up"),    { repeating = true })
hl.bind(mainMod .. " + CTRL + SHIFT + down",  hl.dsp.exec_cmd("python3 ~/scripts/move_window.py down"),  { repeating = true })

-- ========== PINDAH POSISI JENDELA TILED (SUPER + ALT + SHIFT) ==========
hl.bind(mainMod .. " + ALT + SHIFT + left",  hl.dsp.exec_cmd("python3 ~/scripts/move_window_tiled.py left"))
hl.bind(mainMod .. " + ALT + SHIFT + right", hl.dsp.exec_cmd("python3 ~/scripts/move_window_tiled.py right"))
hl.bind(mainMod .. " + ALT + SHIFT + up",    hl.dsp.exec_cmd("python3 ~/scripts/move_window_tiled.py up"))
hl.bind(mainMod .. " + ALT + SHIFT + down",  hl.dsp.exec_cmd("python3 ~/scripts/move_window_tiled.py down"))

-- ========== RESIZE JENDELA FLOATING (SUPER + CTRL + ALT + SHIFT) ==========
hl.bind(mainMod .. " + CTRL + ALT + SHIFT + left",  hl.dsp.exec_cmd("python3 ~/scripts/resize_window.py left"),  { repeating = true })
hl.bind(mainMod .. " + CTRL + ALT + SHIFT + right", hl.dsp.exec_cmd("python3 ~/scripts/resize_window.py right"), { repeating = true })
hl.bind(mainMod .. " + CTRL + ALT + SHIFT + up",    hl.dsp.exec_cmd("python3 ~/scripts/resize_window.py up"),    { repeating = true })
hl.bind(mainMod .. " + CTRL + ALT + SHIFT + down",  hl.dsp.exec_cmd("python3 ~/scripts/resize_window.py down"),  { repeating = true })
