#!/usr/bin/env bash
# Wofi power menu: lock / logout / suspend / reboot / shutdown.
set -euo pipefail

options="\
 Lock\n Logout\n Suspend\n Reboot\n Shutdown"
choice="$(echo -e "$options" | wofi --dmenu --prompt 'Power' | awk '{print $2}')"

case "$choice" in
    Lock)     hyprlock ;;
    Logout)   hyprctl dispatch exit ;;
    Suspend)  systemctl suspend ;;
    Reboot)   systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
    *)        exit 0 ;;
esac