#!/usr/bin/env bash
# Clipboard history picker: cliphist backend + rofi, with image thumbnails.
#
# Image entries render as a thumbnail ONLY (no text label); text entries show
# as text. Selection is by row index (rofi -format i) so image rows can have an
# empty label while still mapping back to the right cliphist entry to decode.
set -uo pipefail

THUMB_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist/thumbs"
THEME="$HOME/.config/rofi/clipboard.rasi"
mkdir -p "$THUMB_DIR"

# Original cliphist lines (id<TAB>preview), index-aligned with the rofi rows.
mapfile -t LINES < <(cliphist list)

emit_rows() {
    local line id preview thumb
    for line in "${LINES[@]}"; do
        id=${line%%$'\t'*}
        preview=${line#*$'\t'}
        case $preview in
            *"binary data"*png*|*"binary data"*jpeg*|*"binary data"*jpg*|\
            *"binary data"*bmp*|*"binary data"*webp*|*"binary data"*gif*)
                thumb="$THUMB_DIR/$id.png"
                if [ ! -s "$thumb" ]; then
                    cliphist decode <<<"$line" | magick - -resize 400x400 -strip "$thumb" 2>/dev/null
                fi
                if [ -s "$thumb" ]; then
                    # empty label + icon -> thumbnail only (null byte goes straight to rofi)
                    printf '\0icon\x1f%s\n' "$thumb"
                else
                    printf '%s\n' "$preview"
                fi
                ;;
            *)
                printf '%s\n' "$preview"
                ;;
        esac
    done
}

idx=$(emit_rows | rofi -dmenu -i -show-icons -p 'Clipboard' -theme "$THEME" -format i) || exit 0
[ -z "$idx" ] && exit 0
cliphist decode <<<"${LINES[$idx]}" | wl-copy
