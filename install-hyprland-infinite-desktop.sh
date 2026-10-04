#!/usr/bin/env bash
#
# installer hyprland-infinite-desktop-v2 (versi lokal)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SCRIPTS="${SCRIPT_DIR}/scripts"
SCRIPTS_DEST="${HOME}/scripts"
HYPR_LUA="${HOME}/.config/hypr/hyprland.lua"

C_RESET="\033[0m"; C_BOLD="\033[1m"; C_GREEN="\033[32m"; C_YELLOW="\033[33m"; C_RED="\033[31m"; C_CYAN="\033[36m"

log()  { echo -e "${C_CYAN}==>${C_RESET} $*"; }
ok()   { echo -e "${C_GREEN}[OK]${C_RESET} $*"; }
warn() { echo -e "${C_YELLOW}[WARNING]${C_RESET} $*"; }
err()  { echo -e "${C_RED}[ERROR]${C_RESET} $*" >&2; }

require_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Deteksi distro dan instal dependensi
install_packages() {
    log "Mendeteksi distro dan menginstal paket yang diperlukan (python, python-evdev, bash, jq)..."

    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        DISTRO_ID="${ID:-unknown}"
        DISTRO_LIKE="${ID_LIKE:-}"
    else
        DISTRO_ID="unknown"
        DISTRO_LIKE=""
    fi

    if [[ "$DISTRO_ID" == "arch" || "$DISTRO_LIKE" == *arch* ]]; then
        sudo pacman -S --needed --noconfirm python python-evdev bash jq
    elif [[ "$DISTRO_ID" == "fedora" || "$DISTRO_LIKE" == *fedora* ]]; then
        sudo dnf install -y python python-evdev bash jq
    elif [[ "$DISTRO_ID" == "ubuntu" || "$DISTRO_ID" == "debian" || "$DISTRO_LIKE" == *debian* ]]; then
        sudo apt update
        sudo apt install -y python3 python3-evdev bash jq
    else
        warn "Tidak dapat mengenali distro Anda secara otomatis (ID=$DISTRO_ID)."
        warn "Silakan instal manual: python3, python-evdev, bash, jq"
    fi
    ok "Paket berhasil diinstal (atau sudah terpasang)."
}


# 2. Keanggotaan grup 'input' (diperlukan oleh python-evdev)
setup_input_group() {
    log "Menambahkan user (${USER}) ke grup 'input'..."
    if groups "$USER" | grep -qw input; then
        ok "User Anda sudah terdaftar di dalam grup 'input'."
    else
        sudo usermod -aG input "$USER"
        warn "User telah ditambahkan ke grup 'input'. Anda harus LOG OUT (atau reboot) agar perubahan berlaku."
        NEED_RELOGIN=1
    fi
}


# 3. Salin skrip dari folder lokal (tanpa download internet / tanpa tertimpa)
install_scripts() {
    if [ ! -d "${LOCAL_SCRIPTS}" ]; then
        err "Folder 'scripts' tidak ditemukan di lokasi: ${LOCAL_SCRIPTS}"
        err "Pastikan skrip installer ini dijalankan dari dalam folder repositori hasil kloningan."
        exit 1
    fi

    log "Membuat direktori ${SCRIPTS_DEST} dan menyalin file skrip lokal..."
    mkdir -p "${SCRIPTS_DEST}"

    # Salin semua file .py, .sh, dan .lua dari direktori scripts lokal
    find "${LOCAL_SCRIPTS}" -maxdepth 1 -type f \( -name "*.py" -o -name "*.sh" -o -name "*.lua" \) -print0 |
        while IFS= read -r -d '' f; do
            cp -f "$f" "${SCRIPTS_DEST}/"
            ok "Tersalin: $(basename "$f")"
        done

    log "Menerapkan izin eksekusi (chmod +x)..."
    chmod +x \
        "${SCRIPTS_DEST}/infinite-desktop.sh" \
        "${SCRIPTS_DEST}/floating_tile_toggle.py" \
        "${SCRIPTS_DEST}/move_window_tiled.py" \
        "${SCRIPTS_DEST}/navigate_windows.py" \
        "${SCRIPTS_DEST}/resize_window.py" \
        "${SCRIPTS_DEST}/move_window.py" \
        "${SCRIPTS_DEST}/infinite_desktop_core.py" \
        "${SCRIPTS_DEST}/recenter_canvas.py" \
        2>/dev/null || true

    [ -f "${SCRIPTS_DEST}/discover_hyprland_api.sh" ] && chmod +x "${SCRIPTS_DEST}/discover_hyprland_api.sh"

    ok "Skrip berhasil dipasang di ${SCRIPTS_DEST}"
}


# 4. Patch hyprland.lua (autostart + import file shortcut terpusat)
patch_hyprland_config() {
    log "Memperbarui ${HYPR_LUA} (autostart + shortcut)..."
    mkdir -p "$(dirname "${HYPR_LUA}")"
    touch "${HYPR_LUA}"

    if grep -q "infinite-shortcuts.lua" "${HYPR_LUA}"; then
        warn "hyprland.lua tidak dimodifikasi (konfigurasi sudah terpasang sebelumnya)."
    else
        echo "" >> "${HYPR_LUA}"
        echo "-- >>> hyprland-infinite-desktop-v2 (auto-installed) START" >> "${HYPR_LUA}"
        echo "hl.on(\"hyprland.start\", function()" >> "${HYPR_LUA}"
        echo "    hl.exec_cmd(\"python3 ~/scripts/infinite_desktop_core.py 1.6 > /tmp/infinite-desktop.log 2>&1\")" >> "${HYPR_LUA}"
        echo "end)" >> "${HYPR_LUA}"
        echo "dofile(os.getenv(\"HOME\") .. \"/scripts/infinite-shortcuts.lua\")" >> "${HYPR_LUA}"
        echo "-- <<< hyprland-infinite-desktop-v2 (auto-installed) END" >> "${HYPR_LUA}"
        ok "hyprland.lua berhasil diperbarui."
    fi
}


# Main
NEED_RELOGIN=0

echo -e "${C_BOLD}Installer hyprland-infinite-desktop-v2 (Offline/Lokal)${C_RESET}"
echo ""

install_packages
setup_input_group
install_scripts
patch_hyprland_config

echo ""
ok "Instalasi selesai."
echo ""
echo "Catatan:"
echo "  - Muat ulang Hyprland (hyprctl reload) atau restart sesi untuk menerapkan shortcut."
if [ "${NEED_RELOGIN:-0}" -eq 1 ]; then
    warn "  - Anda harus log out / reboot agar keanggotaan grup 'input' aktif (dibutuhkan python-evdev)."
fi
