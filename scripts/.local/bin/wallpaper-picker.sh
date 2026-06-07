#!/usr/bin/env bash
# Pick a wallpaper from ~/.config/backgrounds via wofi and apply with hyprpaper.
set -euo pipefail
DIR="$HOME/.config/backgrounds"

choice="$(ls -1 "$DIR" | wofi --dmenu --prompt 'Wallpaper')"
[ -z "${choice:-}" ] && exit 0
img="$DIR/$choice"

hyprctl hyprpaper preload "$img"
hyprctl hyprpaper wallpaper ",$img"

# Persist for next login (this file is a stow symlink into the dotfiles repo)
{
    echo "preload = $img"
    echo "wallpaper = ,$img"
} > "$HOME/.config/hypr/hyprpaper.conf"