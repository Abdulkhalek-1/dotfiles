#!/usr/bin/env bash
# Apply the wallpaper via hyprpaper IPC at startup.
#
# hyprpaper's conf-based apply races on this version ("Monitor ... has no
# target") and often shows no wallpaper on login. The `wallpaper` IPC call
# auto-loads the image and works reliably, so we drive it here with a retry
# until hyprpaper is up. The chosen image is read from hyprpaper.conf (which
# the wallpaper picker writes), so this stays the single source of truth.
set -uo pipefail

CONF="$HOME/.config/hypr/hyprpaper.conf"
img=$(awk -F, '/^[[:space:]]*wallpaper/ {print $NF; exit}' "$CONF" 2>/dev/null | xargs)
img="${img/#\~/$HOME}"
[ -z "${img:-}" ] && exit 0

for _ in $(seq 30); do
    if hyprctl hyprpaper wallpaper ",$img" 2>/dev/null | grep -qi ok; then
        exit 0
    fi
    sleep 0.2
done
