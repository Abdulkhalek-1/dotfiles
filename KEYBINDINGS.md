# Keybindings & Shortcuts Reference

The complete keymap for this Hyprland config.

**Modifier:** `Super` = the Windows/Meta key (`$mainMod`).
**Defaults:** terminal `ghostty` · launcher `wofi` · files `nautilus` · browser system default.

---

## Apps

| Shortcut | Action |
|---|---|
| `Super` + `Return` | Open terminal (Ghostty) |
| `Super` + `Space` | App launcher (wofi) |
| `Super` + `E` | File manager (nautilus) |
| `Super` + `B` | Web browser |
| `Super` + `V` | Clipboard history (cursor-clip overlay) |

## Window management

| Shortcut | Action |
|---|---|
| `Super` + `Q` | Close active window |
| `Super` + `F` | Fullscreen |
| `Super` + `T` | Toggle floating |
| `Super` + `P` | Pseudo-tile (dwindle) |
| `Super` + `J` | Toggle split direction |

### Move focus (Vim keys)

| Shortcut | Action |
|---|---|
| `Super` + `H` | Focus left |
| `Super` + `L` | Focus right |
| `Super` + `K` | Focus up |
| `Super` + `J`* | Focus down |

\* `Super`+`J` toggles split **and** focuses down — Hyprland runs the matching dispatcher per context.

### Move window (Shift + Vim keys)

| Shortcut | Action |
|---|---|
| `Super` + `Shift` + `H` | Move window left |
| `Super` + `Shift` + `L` | Move window right |
| `Super` + `Shift` + `K` | Move window up |
| `Super` + `Shift` + `J` | Move window down |

## Workspaces

| Shortcut | Action |
|---|---|
| `Super` + `1`…`0` | Switch to workspace 1–10 |
| `Super` + `Shift` + `1`…`0` | Move window to workspace 1–10 |
| `Super` + `S` | Toggle scratchpad (special workspace) |
| `Super` + `Shift` + `S` | Move window to scratchpad |

## Mouse & touchpad

| Input | Action |
|---|---|
| `Super` + scroll | Cycle workspaces |
| `Super` + left-drag | Move window |
| `Super` + right-drag | Resize window |
| 3-finger swipe (touchpad) | Switch workspaces |

## Session & system

| Shortcut | Action |
|---|---|
| `Super` + `L` | Lock screen (hyprlock) |
| `Super` + `Escape` | Power menu (lock / logout / suspend / reboot / shutdown) |
| `Super` + `Shift` + `R` | Reload Hyprland config |
| `Super` + `Shift` + `W` | Wallpaper picker (wofi) |

## Screenshots

| Shortcut | Action |
|---|---|
| `Print` | Region capture + annotate (flameshot GUI) |
| `Shift` + `Print` | Full screenshot → clipboard |

## Function keys (laptop)

| Key | Action |
|---|---|
| Volume Up / Down | Sink volume ±5% |
| Mute | Toggle output mute |
| Mic Mute | Toggle microphone mute |
| Brightness Up / Down | Screen brightness ±5% (floored at 5% — never blacks out) |
| ▶ / ⏭ / ⏮ | Play-pause / next / previous (playerctl) |
| `Alt` + `Shift` | Switch keyboard layout (US ⇄ Arabic) |

## Laptop lid

| Action | Behavior |
|---|---|
| Close lid | Lock session |
| Open lid | Wake display |

---

## Clipboard (cursor-clip)

Open with `Super` + `V`. The overlay appears at your cursor and is fully keyboard-driven:

| Key | Action |
|---|---|
| `↑` `↓` or `J` / `K` | Navigate entries |
| `Enter` | Paste selected entry |
| type text | Filter / search history |
| `P` | Pin entry |
| `Delete` | Remove entry |
| `Esc` | Close |

History (text + images) persists across reboots. Password-manager content is auto-excluded.

## Power menu (`Super` + `Escape`)

A wofi menu with: **Lock · Logout · Suspend · Reboot · Shutdown**. Navigate with arrows / type to filter, `Enter` to confirm, `Esc` to cancel.

## Launcher (`Super` + `Space`)

wofi in drun mode with icons. Type to filter, `↑`/`↓` to navigate, `Enter` to launch, `Esc` to dismiss.

---

## Behavior notes

- **Idle/lock** runs **only on battery**. On AC power there is no dimming, locking, or suspend (`idle-on-battery.sh`).
- **Brightness** can't drop below **5%** — the slider and brightness keys are clamped at the source so the screen never fully blacks out.
- See [README.md](README.md) for the tool stack and install steps.

To change any binding, edit [`hyprland/.config/hypr/keybinds.conf`](hyprland/.config/hypr/keybinds.conf) and reload with `Super`+`Shift`+`R`.
