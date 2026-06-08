#!/usr/bin/env bash
# Wofi power menu: lock / logout / suspend / reboot / shutdown.
set -euo pipefail

options="Lock
Logout
Suspend
Reboot
Shutdown"

# `|| exit 0` so cancelling wofi (Escape -> exit 1) ends cleanly under set -e.
choice="$(printf '%s\n' "$options" | wofi --dmenu --prompt 'Power')" || exit 0

case "$choice" in
    Lock)     hyprlock ;;
    Logout)   hyprctl dispatch exit ;;
    Suspend)  systemctl suspend ;;
    Reboot)   systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
    *)        exit 0 ;;
esac
