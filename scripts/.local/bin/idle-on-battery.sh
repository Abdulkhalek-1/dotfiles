#!/usr/bin/env bash
# Run hypridle only on battery. On AC power, no idle management at all
# (no dim / lock / dpms / suspend). Reacts to power-supply udev events.
set -uo pipefail

ac_online() {
    local f
    for f in /sys/class/power_supply/*/; do
        [ "$(cat "$f/type" 2>/dev/null)" = "Mains" ] || continue
        [ "$(cat "$f/online" 2>/dev/null)" = "1" ] && return 0
    done
    return 1
}

apply() {
    if ac_online; then
        pkill -x hypridle 2>/dev/null
        hyprctl dispatch dpms on >/dev/null 2>&1   # make sure the screen is on
    else
        pgrep -x hypridle >/dev/null || hypridle >/dev/null 2>&1 &
    fi
}

apply
# react to AC plug / unplug
udevadm monitor --udev --subsystem-match=power_supply | while read -r _; do
    apply
done
