#!/usr/bin/env bash
# Install packages and stow all dotfile configs.
set -euo pipefail
cd "$(dirname "$0")"

echo ">> Installing pacman packages..."
mapfile -t PKGS < <(grep -vE '^\s*#|^\s*$' packages.txt | sed '/AUR/Q')
sudo pacman -S --needed "${PKGS[@]}"

echo ">> Installing AUR packages (needs paru or yay)..."
AUR=(hyprpanel-bin clipse wl-clip-persist)
if command -v paru >/dev/null;   then paru -S --needed "${AUR[@]}"
elif command -v yay >/dev/null;  then yay  -S --needed "${AUR[@]}"
else echo "!! No AUR helper found. Install paru/yay, then: paru -S ${AUR[*]}"; fi

echo ">> Enabling services..."
sudo systemctl enable --now NetworkManager bluetooth power-profiles-daemon

echo ">> Stowing configs..."
PACKAGES=(hyprland hyprlock hyprpaper ghostty wofi starship hyprpanel \
          scripts backgrounds nvim zshrc)
for p in "${PACKAGES[@]}"; do
    [ -d "$p" ] && stow -R "$p" && echo "   stowed $p"
done

echo ">> Done. Log into Hyprland and reload (Super+Shift+R)."