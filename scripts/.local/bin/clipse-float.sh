#!/usr/bin/env bash
# Open clipse clipboard history in a floating terminal window.
#
# Ghostty needs --gtk-single-instance=false AND a dotted GTK app-id for the
# window class to actually be set; the Hyprland rule in rules.conf matches
# `match:class (.*clipse.*)` to float + center + size this window.
exec ghostty --gtk-single-instance=false --class=clipse.clipboard -e clipse