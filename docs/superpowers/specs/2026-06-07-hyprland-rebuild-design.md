# Design: Abdulkhalek's Hyprland — clean dev-focused dotfiles rebuild

**Date:** 2026-06-07
**Status:** Approved (design), pending implementation plan
**Author:** Abdulkhalek (with Claude)

## Summary

Full from-scratch rebuild of the dotfiles (currently a fork of
`typecraft-dev/dotfiles`). The existing setup is cluttered (3 terminals, 3
launchers, a dead X11 stack alongside the Wayland one) and under-configured
(good tools installed but never wired up — no clipboard manager, conflicting
notification daemons, an unused comprehensive panel).

This rebuild stays on **Hyprland (Wayland)**, deletes the dead weight, and
assembles one cohesive, **laptop-first, dev-focused** environment with a
comprehensive bar, a pretty image-capable clipboard, proper screenshots, and a
clean documented keybind scheme.

## Goals

- One opinionated, coherent stack — no redundant tools.
- Everything installed is actually wired into config.
- Laptop-aware: battery, power profiles, idle/lock, touchpad gestures.
- Reproducible on a fresh machine via GNU Stow + an `install.sh`.
- The repo becomes genuinely the user's own (detached from upstream).

## Non-goals

- Rebuilding the Neovim config. User stays on **VS Code for now** and will move
  to Neovim later. The existing `nvim/` config is left untouched.
- A multiplexer. Ghostty's native splits/tabs replace tmux.
- Animated wallpapers / heavy eye-candy beyond the chosen theme.

## Final tool stack

| Slot | Choice | Removed / replaced |
|---|---|---|
| Compositor | Hyprland | — |
| Terminal | Ghostty | kitty, alacritty |
| Launcher | wofi (with icons) | rofi, fuzzel |
| Bar + controls + notifications | HyprPanel | waybar, swaync, dunst |
| Clipboard | clipse (image thumbnails, persistent) + `wl-clip-persist` | — |
| Screenshots | flameshot (already installed as flameshot-git) | hyprshot raw flow |
| Lock / idle | hyprlock + hypridle | — |
| Wallpaper | hyprpaper + wofi wallpaper-switcher script | hyprmocha |
| Shell prompt | starship (keep) | — |
| Multiplexer | none (Ghostty splits/tabs) | tmux |
| Editor | VS Code (themed Catppuccin Mocha); nvim deferred | — |
| Theme | Catppuccin Mocha everywhere | xresources, screenlayout (X11) |

**Deleted entirely:** `i3`, `picom`, `polybar`, `xresources`, `screenlayout`
(X11 stack); `kitty`, `alacritty` (extra terminals); `rofi` (extra launcher);
`tmux`; `hyprmocha` (old theme dir); the stray `tempCodeRunnerFile.python`.

**Kept:** `backgrounds/`, `nvim/` (untouched, for later), `starship/`, `wofi/`,
`ghostty/`, `hyprland/`, `hyprlock/`, `hyprpaper/`.

### Notes / caveats discovered during design

- HyprPanel (`hyprpanel-bin`) is already installed; it provides the bar,
  audio/mic sliders, Bluetooth & Wi-Fi toggles + device pickers, battery + power
  profile, brightness, media player, calendar, tray, dashboard, **and a built-in
  notification center** — so no separate notification daemon is needed.
- `clipse` is installed from the AUR; `wl-clip-persist` is in `extra`.
- `flameshot-git` is installed. Flameshot on Hyprland/Wayland can need the XDG
  portal / a launch tweak; implementation must verify the region-capture flow
  actually works and document any wrapper needed.
- `power-profiles-daemon` backs HyprPanel's power-profile toggle.

## Laptop-first behavior

- **hypridle** ladder: dim → lock (hyprlock) → screen off (DPMS) → suspend, with
  separate, sane timings on battery vs AC.
- **Lid close** → lock + suspend.
- **Power profiles** via `power-profiles-daemon`, toggled from HyprPanel.
- **Touchpad**: tap-to-click, natural scroll, 3-finger workspace swipe.
- **Function keys**: brightness, volume, mic mute, media play/pause/next/prev.
- HyprPanel surfaces battery %, Wi-Fi, Bluetooth, and power profile in the bar.

## Keybinds (Super = main modifier)

Documented and grouped with comments in `hyprland.conf`. Initial scheme
(rebindable):

| Bind | Action |
|---|---|
| `Super+Return` | terminal (Ghostty) |
| `Super+Space` | launcher (wofi) |
| `Super+E` | file manager |
| `Super+B` | browser |
| `Super+V` | clipboard manager (clipse, floating) |
| `Print` | flameshot region capture |
| `Super+L` | lock (hyprlock) |
| `Super+Q` | close active window |
| `Super+F` | fullscreen |
| `Super+T` | toggle floating |
| `Super+hjkl` | move focus |
| `Super+1..0` | switch workspace |
| `Super+Shift+1..0` | move window to workspace |
| `Super+Shift+R` | reload Hyprland |
| `Super+Escape` | power menu |
| `XF86*` | volume / brightness / media keys |

Full final table lives in the implemented `hyprland.conf`.

## Repo & structure

- Keep the **GNU Stow** layout: one folder per app whose contents mirror `$HOME`
  (e.g. `ghostty/.config/ghostty/...`), so `stow ghostty` symlinks correctly.
- **Detach from upstream** `typecraft-dev/dotfiles`; this is now the user's own.
- Add a real **README**: what's included, dependency list, install steps, a
  screenshots placeholder section.
- Add **`install.sh`**: installs all required packages (pacman + AUR) and stows
  every config on a fresh machine. Idempotent where practical.
- Keep `backgrounds/`.

## Theming

Catppuccin Mocha across Ghostty, wofi, HyprPanel, hyprlock, clipse, and VS Code
for a single consistent palette. Cursor: catppuccin-mocha-dark-cursors (already
in use).

## Success criteria

- A fresh `git clone` + `./install.sh` yields a working Hyprland desktop.
- Clipboard history (with images) opens on `Super+V` and survives a reboot.
- Screenshots: region capture + annotate works via the bound key.
- HyprPanel shows working audio/Wi-Fi/Bluetooth/battery/power-profile controls
  and notifications appear in its center.
- No X11 / redundant-tool leftovers remain in the repo.
- Idle/lock/lid behavior works on battery and AC.
