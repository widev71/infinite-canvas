# 🌌 Hyprland Infinite Desktop v2

Skrip cerdas untuk mengubah workspace **Hyprland** Anda menjadi sebuah **kanvas tanpa batas (Infinite Canvas)** ala Miro/Figma. Seluruh jendela *floating* dapat digeser secara bersamaan (*panning*) menggunakan mouse, bernavigasi mulus antar-jendela dengan keyboard, serta mendukung inersia gerak yang halus dan sistem shortcut anti-bentrok.

<img width="1920" height="1080" alt="Hyprland Infinite Desktop Preview" src="https://github.com/user-attachments/assets/464fa371-7cc4-4fd5-a06c-55d7b51ba59d" />

---

## 🚀 Fitur Utama

- **🌊 Infinite Canvas Panning:** Geser seluruh kanvas desktop hanya dengan menahan tombol modifier dan menggerakkan mouse.
- **⚡ Smooth Inertia & Momentum:** Kanvas meluncur mulus dengan perlambatan gesekan alami saat dilepas.
- **🎯 Recenter / Home View:** Kembalikan seluruh jendela ke tengah layar secara instan jika tergeser terlalu jauh.
- **🔄 Toggle Tiling & Floating:** Beralih antara mode kanvas bebas (*floating*) dan mode susun rapi (*tiling*) dengan posisi jendela yang tersimpan otomatis.
- **🧭 Navigasi Cerdas:** Pindah fokus sekaligus memusatkan kamera monitor langsung ke jendela target.
- **⌨️ Pusat Shortcut Tunggal:** Seluruh kombinasi tombol terpusat di `~/scripts/infinite-shortcuts.lua` dengan kombinasi **3+ tombol modifier** sehingga **100% bebas bentrok** dari keybind bawaan distro.
- **🌐 Berbahasa Indonesia:** Seluruh pesan diagnostik, installer, dan log runtime ramah Bahasa Indonesia.

---

## 📋 Apa yang Harus Disiapkan? (Prasyarat)

Sebelum memasang, pastikan sistem Anda memenuhi kebutuhan berikut:

1. **Lingkungan Desktop:** Linux dengan compositor **Hyprland** (disarankan v0.55+ dengan konfigurasi `hyprland.lua` atau dukungan soket IPC).
2. **Paket Ketergantungan:**
   - `python3` (penerjemah kode utama)
   - `python-evdev` (pembaca input perangkat mouse/keyboard tingkat rendah)
   - `bash` (shell interpreter)
   - `jq` (pemroses JSON data Hyprland)
3. **Izin Grup Perangkat (`input` group):** User Anda harus terdaftar di dalam grup sistem `input` agar skrip Python memiliki izin membaca pergerakan mouse/keyboard tanpa memerlukan akses root.

---

## ⚠️ Apa yang TIDAK Boleh Dilakukan? (PENTING!)

Harap perhatikan pantangan berikut agar sistem Anda tidak mengalami error:

1. ❌ **JANGAN jalankan installer dengan `sudo` langsung (`sudo ./install...`)!**
   * *Alasan:* Jika dijalankan sebagai root, file akan dipasang di `/root/scripts/` bukan di `/home/user/scripts/`, dan hak milik file akan kacau. Jalankan sebagai user biasa: `./install-hyprland-infinite-desktop.sh`. Skrip otomatis meminta password `sudo` jika perlu menginstal paket.
2. ❌ **JANGAN lupa Log Out atau Restart setelah instalasi!**
   * *Alasan:* Linux memerlukan pembaruan sesi agar penambahan user ke grup `input` mulai berlaku. Jika belum restart/log out, Anda akan menemui error *Permission Denied* pada evdev.
3. ❌ **JANGAN hapus atau ubah nama folder `~/scripts` sembarangan!**
   * *Alasan:* Konfigurasi `hyprland.lua` memanggil skrip dari path absolut `~/scripts/`. Jika dipindahkan, Hyprland tidak akan menemukan skripnya.
4. ❌ **JANGAN gunakan shortcut 1-2 tombol umum jika mengubah keybind!**
   * *Alasan:* Shortcut seperti `SUPER + 1..9`, `SUPER + D`, atau `SUPER + Panah` adalah tombol bawaan sistem operasi. Gunakan minimal 3 modifier (contoh: `SUPER + CTRL + ALT + ...`) untuk mencegah bentrok fungsi.

---

## 📥 Langkah-Langkah Penginstalan

### Metode 1: Otomatis (Sangat Direkomendasikan)

Installer lokal akan mendeteksi distro Anda, menginstal paket dependensi, menambahkan user ke grup `input`, menyalin skrip lokal ke `~/scripts/`, dan mendaftarkan autostart ke konfigurasi Hyprland:

1. **Kloning repositori dan masuk ke direktori:**
   ```bash
   git clone https://github.com/widev71/infinite-canvas.git
   cd infinite-canvas
   ```

2. **Berikan izin eksekusi dan jalankan installer:**
   ```bash
   chmod +x install-hyprland-infinite-desktop.sh
   ./install-hyprland-infinite-desktop.sh
   ```

3. **Restart sesi Anda:**
   ```bash
   reboot
   ```
   *(Atau cukup Log Out dan Login kembali agar izin grup input aktif).*

---

### Metode 2: Manual

Jika Anda ingin mengatur semuanya secara manual tanpa skrip otomatis:

1. **Instal paket sesuai distro Anda:**
   * **Arch Linux:**
     ```bash
     sudo pacman -S --needed python python-evdev bash jq
     ```
   * **Fedora:**
     ```bash
     sudo dnf install -y python python-evdev bash jq
     ```
   * **Ubuntu / Debian:**
     ```bash
     sudo apt update && sudo apt install -y python3 python3-evdev bash jq
     ```

2. **Tambahkan user Anda ke grup `input`:**
   ```bash
   sudo usermod -aG input $USER
   ```

3. **Buat direktori dan salin skrip:**
   ```bash
   mkdir -p ~/scripts
   cp scripts/*.py scripts/*.sh scripts/*.lua ~/scripts/
   chmod +x ~/scripts/*.sh ~/scripts/*.py
   ```

4. **Tambahkan konfigurasi ke `~/.config/hypr/hyprland.lua`:**
   Buka file `hyprland.lua` Anda dan tambahkan baris berikut di akhir:
   ```lua
   -- >>> hyprland-infinite-desktop-v2 START
   hl.on("hyprland.start", function()
       hl.exec_cmd("python3 ~/scripts/infinite_desktop_core.py 1.6 > /tmp/infinite-desktop.log 2>&1")
   end)
   dofile(os.getenv("HOME") .. "/scripts/infinite-shortcuts.lua")
   -- <<< hyprland-infinite-desktop-v2 END
   ```

5. **Restart komputer atau sesi Hyprland Anda:**
   ```bash
   reboot
   ```

---

## ⌨️ Panduan Penggunaan & Daftar Shortcut

Semua shortcut menggunakan kombinasi **3+ tombol modifier** untuk menjamin **0% resiko bentrok** dengan tombol bawaan sistem atau aplikasi:

| Aksi / Fungsi | Tombol Shortcut | Keterangan |
| :--- | :--- | :--- |
| **🌊 Panning Kanvas** | Tahan **`SUPER + ALT`** + Geser Mouse | Menyeret seluruh jendela di kanvas desktop secara bersamaan |
| **🎯 Recenter / Reset Kanvas** | **`SUPER + CTRL + ALT + 0`** | Menarik semua jendela kembali ke tengah monitor (*Home View*) |
| **🔄 Alih Mode (Tiling / Floating)** | **`SUPER + CTRL + ALT + D`** | Beralih antara mode susun rapi dan mode kanvas bebas |
| **🧭 Navigasi Antar-Jendela** | **`SUPER + CTRL + ALT + Panah`** | Memindahkan fokus kamera monitor ke jendela target |
| **🖐️ Pindahkan Jendela Floating** | **`SUPER + CTRL + SHIFT + Panah`** | Menggeser jendela aktif di atas kanvas |
| **🪟 Geser Posisi Jendela Tiled** | **`SUPER + ALT + SHIFT + Panah`** | Menukar posisi jendela saat berada di mode tiling |
| **📐 Ubah Ukuran (Resize) Jendela** | **`SUPER + CTRL + ALT + SHIFT + Panah`** | Memperbesar atau memperkecil jendela floating |
| **🗂️ Pindah Workspace Sebelumnya** | **`SUPER + CTRL + SHIFT + Z`** | Berpindah ke ruang kerja (*workspace*) sebelumnya |
| **🗂️ Pindah Workspace Berikutnya** | **`SUPER + CTRL + SHIFT + X`** | Berpindah ke ruang kerja (*workspace*) berikutnya |
| **📦 Lempar Jendela ke WS Prev** | **`SUPER + ALT + SHIFT + Z`** | Memindahkan jendela aktif ke workspace sebelumnya |
| **📦 Lempar Jendela ke WS Next** | **`SUPER + ALT + SHIFT + X`** | Memindahkan jendela aktif ke workspace berikutnya |

> **💡 Tips Kustomisasi:** Ingin mengganti kombinasi tombol? Cukup edit file `~/scripts/infinite-shortcuts.lua` lalu jalankan `hyprctl reload` di terminal!

---

## 🛠️ Pemecahan Masalah (Troubleshooting)

- **Kanvas tidak bergeser saat menahan `SUPER + ALT`:**
  Periksa apakah user Anda sudah aktif di grup `input` dengan mengetik `groups` di terminal. Jika kata `input` belum ada, jalankan `sudo usermod -aG input $USER` lalu **reboot**.
- **Memeriksa log background:**
  Buka terminal dan jalankan:
  ```bash
  cat /tmp/infinite-desktop.log
  ```
- **Menguji kompabilitas API Hyprland:**
  Jalankan alat diagnostik bawaan untuk memastikan dispatcher Hyprland Anda merespons dengan benar:
  ```bash
  bash ~/scripts/discover_hyprland_api.sh
  ```
