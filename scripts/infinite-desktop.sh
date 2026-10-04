#!/usr/bin/env bash
sleep 3
SPEED=1.6

#ruta deseada /home/usuario/scripts/
# Obtener el directorio donde está este script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detectar teclado - priorizando teclados reales (sin "mouse" en el nombre)
KBD_DEV=$(python3 -c "
import glob, os

# Palabras que indican que NO es un teclado real
ignore_words = ['mouse', 'optical', 'system control', 'consumer control']
real_keyboard = None

for dev in sorted(glob.glob('/dev/input/event*')):
    try:
        with open('/sys/class/input/'+os.path.basename(dev)+'/device/name') as f:
            name = f.read().strip().lower()
        
        # Si tiene palabras a ignorar, saltar
        if any(word in name for word in ignore_words):
            continue
            
        # Verificar que sea un teclado
        if 'keyboard' in name or 'kbd' in name or 'gaming keyboard' in name:
            with open('/sys/class/input/'+os.path.basename(dev)+'/device/capabilities/ev') as f:
                caps = int(f.read().strip(), 16)
            if caps & 0x1:  # Tiene EV_KEY
                real_keyboard = dev
                break
    except:
        continue

# Si no encontramos un teclado "limpio", buscar cualquier teclado que no sea del ratón
if not real_keyboard:
    for dev in sorted(glob.glob('/dev/input/event*')):
        try:
            with open('/sys/class/input/'+os.path.basename(dev)+'/device/name') as f:
                name = f.read().strip().lower()
            
            # Excluir explícitamente el teclado del ratón
            if 'optical mouse keyboard' in name:
                continue
                
            if 'keyboard' in name or 'kbd' in name:
                with open('/sys/class/input/'+os.path.basename(dev)+'/device/capabilities/ev') as f:
                    caps = int(f.read().strip(), 16)
                if caps & 0x1:
                    real_keyboard = dev
                    break
        except:
            continue

print(real_keyboard if real_keyboard else '')
")

# Detectar ratón - buscar el dispositivo que es específicamente un mouse
MOUSE_DEV=$(python3 -c "
import glob, os
mouse_found = None
for dev in sorted(glob.glob('/dev/input/event*')):
    try:
        # Verificar que tenga capacidades de movimiento
        with open('/sys/class/input/'+os.path.basename(dev)+'/device/capabilities/rel') as f:
            caps = int(f.read().strip(), 16)
        if caps & 0b11:
            with open('/sys/class/input/'+os.path.basename(dev)+'/device/name') as f:
                name = f.read().strip().lower()
            
            # Priorizar el que dice "mouse" y no tiene "keyboard"
            if 'mouse' in name and 'keyboard' not in name:
                print(dev)
                break
            elif 'optical' in name and not mouse_found:
                mouse_found = dev
    except:
        continue

if not mouse_found:
    print('')
")

# Verifikasi deteksi
if [ -z "$KBD_DEV" ]; then
    echo "❌ Error: Keyboard tidak dapat dideteksi" >&2
    echo "Perangkat keyboard yang ditemukan:" >&2
    for dev in /dev/input/event*; do
        name=$(cat "/sys/class/input/$(basename $dev)/device/name" 2>/dev/null)
        if echo "$name" | grep -qi "keyboard\|kbd"; then
            echo "  $dev: $name" >&2
        fi
    done
    exit 1
fi

if [ -z "$MOUSE_DEV" ]; then
    echo "❌ Error: Mouse tidak dapat dideteksi" >&2
    echo "Perangkat mouse yang ditemukan:" >&2
    for dev in /dev/input/event*; do
        name=$(cat "/sys/class/input/$(basename $dev)/device/name" 2>/dev/null)
        if echo "$name" | grep -qi "mouse\|optical"; then
            echo "  $dev: $name" >&2
        fi
    done
    exit 1
fi

echo "✅ Terdeteksi: keyboard=$KBD_DEV mouse=$MOUSE_DEV"

# Verifikasi keamanan
if [ "$KBD_DEV" = "$MOUSE_DEV" ]; then
    echo "❌ ERROR: Keyboard dan mouse terdeteksi sebagai perangkat yang sama" >&2
    exit 1
fi

exec python3 "$SCRIPT_DIR/infinite_desktop_core.py" "$KBD_DEV" "$MOUSE_DEV" "$SPEED"
