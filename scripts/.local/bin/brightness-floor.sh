#!/usr/bin/env bash
# Keep the screen backlight at >= MIN_PCT so the HyprPanel slider / brightness
# keys can never fully black out the screen. Event-driven via backlight udev
# events (the backlight emits a "change" uevent on every brightness write).
set -uo pipefail

MIN_PCT=5
dev=$(ls /sys/class/backlight/ 2>/dev/null | head -1)
[ -z "$dev" ] && exit 0
max=$(brightnessctl -d "$dev" m)
min=$(( max * MIN_PCT / 100 ))

clamp() {
    local cur
    cur=$(brightnessctl -d "$dev" g)
    if [ "$cur" -lt "$min" ]; then
        brightnessctl -d "$dev" -q s "${MIN_PCT}%"
    fi
}

clamp
udevadm monitor --udev --subsystem-match=backlight | while read -r line; do
    case $line in *backlight*) clamp ;; esac
done
