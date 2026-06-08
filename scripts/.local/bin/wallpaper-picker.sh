#!/usr/bin/env bash
# Pick a wallpaper from ~/.config/backgrounds via wofi and apply with hyprpaper.
set -euo pipefail
DIR="$HOME/.config/backgrounds"

# `|| exit 0` so cancelling wofi (Escape -> exit 1) ends cleanly under set -e.
choice="$(ls -1 "$DIR" | wofi --dmenu --prompt 'Wallpaper')" || exit 0
[ -z "${choice:-}" ] && exit 0
img="$DIR/$choice"

# hyprpaper 0.8: `wallpaper` auto-loads the image; the separate IPC `preload`
# subcommand is rejected ("invalid hyprpaper request"), so we don't call it.
hyprctl hyprpaper wallpaper ",$img"

# Persist for next login (this file is a stow symlink into the dotfiles repo)
{
    echo "preload = $img"
    echo "wallpaper = ,$img"
} > "$HOME/.config/hypr/hyprpaper.conf"