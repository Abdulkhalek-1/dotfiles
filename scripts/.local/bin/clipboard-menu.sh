#!/usr/bin/env bash
# Clipboard history picker: cliphist backend + rofi, with image thumbnails.
#
# Image entries are decoded to cached thumbnails and shown as rofi icons;
# text entries show as-is. Selecting an entry copies it back to the clipboard.
set -uo pipefail

THUMB_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist/thumbs"
THEME="$HOME/.config/rofi/clipboard.rasi"
mkdir -p "$THUMB_DIR"

build_list() {
    cliphist list | while IFS= read -r line; do
        id=${line%%$'\t'*}
        preview=${line#*$'\t'}
        case $preview in
            *"binary data"*png*|*"binary data"*jpeg*|*"binary data"*jpg*|\
            *"binary data"*bmp*|*"binary data"*webp*|*"binary data"*gif*)
                thumb="$THUMB_DIR/$id.png"
                if [ ! -s "$thumb" ]; then
                    cliphist decode <<<"$line" | magick - -resize 200x200 -strip "$thumb" 2>/dev/null
                fi
                if [ -s "$thumb" ]; then
                    printf '%s\0icon\x1f%s\n' "$line" "$thumb"
                else
                    printf '%s\n' "$line"
                fi
                ;;
            *)
                printf '%s\n' "$line"
                ;;
        esac
    done
}

selected=$(build_list | rofi -dmenu -i -show-icons -p 'Clipboard' -theme "$THEME") || exit 0
[ -z "$selected" ] && exit 0
cliphist decode <<<"$selected" | wl-copy
