# Abdulkhalek's Dotfiles

A clean, laptop-first **Hyprland** (Wayland) setup focused on development.
Catppuccin Mocha throughout. Managed with GNU Stow.

## Stack

| Component | Tool |
|---|---|
| Compositor | Hyprland |
| Terminal | Ghostty |
| Launcher | wofi (with icons) |
| Bar + controls + notifications | HyprPanel |
| Clipboard (native GUI, keyboard-first, image previews, persistent) | cursor-clip |
| Screenshots | flameshot |
| Lock / idle | hyprlock + hypridle |
| Wallpaper | hyprpaper (+ wofi picker) |
| Shell | zsh + Powerlevel10k (oh-my-zsh + zinit) |
| Font | JetBrainsMono Nerd Font |
| Theme | Catppuccin Mocha |

## Install (fresh Arch machine)

```bash
git clone https://github.com/Abdulkhalek-1/dotfiles-1.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` installs the packages in [`packages.txt`](packages.txt) (pacman +
AUR) and stows every config. An AUR helper (`paru`/`yay`) is required for
`hyprpanel-bin`, `clipse`, and `wl-clip-persist`.

## Layout

GNU Stow: each top-level folder mirrors `$HOME`. `stow <folder>` symlinks it
into place (e.g. `stow ghostty` → `~/.config/ghostty/...`).

```
hyprland/   hyprlock/   hyprpaper/   ghostty/   wofi/
hyprpanel/  p10k/       scripts/     backgrounds/  nvim/  zshrc/  cursor-clip/
```

The Hyprland config is split into focused, sourced files under
`hyprland/.config/hypr/`: `hyprland.conf` (main), `keybinds.conf`,
`autostart.conf`, `rules.conf`, `hypridle.conf`, `mocha.conf` (colors).

## Key bindings (highlights)

Full keymap (including clipboard overlay, function keys, and lid behavior):
**[KEYBINDINGS.md](KEYBINDINGS.md)**.

| Bind | Action |
|---|---|
| `Super`+`Return` | terminal (Ghostty) |
| `Super`+`Space` | launcher (wofi) |
| `Super`+`E` | file manager |
| `Super`+`V` | clipboard history (cursor-clip overlay) |
| `Print` | screenshot region (flameshot) |
| `Shift`+`Print` | full screenshot to clipboard |
| `Super`+`L` | lock |
| `Super`+`Escape` | power menu |
| `Super`+`Shift`+`W` | wallpaper picker |
| `Super`+`Q` | close window |
| `Super`+`F` | fullscreen |
| `Super`+`hjkl` | move focus |
| `Super`+`1..0` | switch workspace |

## Notes

- Targets **Hyprland 0.55+** (window-rule / gesture syntax differs from older
  versions — see comments in `rules.conf`).
- HyprPanel provides the bar, system controls, and notifications — there is no
  separate notification daemon. Fine-tune it via its settings GUI
  (`hyprpanel configure`); the result lives in `hyprpanel/.config/hyprpanel/`.
- VS Code is intentionally not tracked here.

## Screenshots

_TODO: add screenshots._
