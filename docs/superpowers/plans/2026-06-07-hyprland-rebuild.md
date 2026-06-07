# Hyprland Dotfiles Rebuild — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the dotfiles into one clean, laptop-first, dev-focused Hyprland setup — deleting the dead X11/redundant-tool weight and properly wiring up every tool (HyprPanel bar, clipse clipboard, flameshot, idle/lock, wallpaper + power menus).

**Architecture:** GNU Stow layout (one folder per app mirroring `$HOME`). Hyprland sources a self-contained Catppuccin `mocha.conf` for colors. HyprPanel provides the bar + system controls + notifications (no waybar/swaync). A reproducible `install.sh` installs packages and stows everything.

**Tech Stack:** Hyprland, Ghostty, wofi, HyprPanel, clipse, wl-clip-persist, flameshot, hyprlock, hypridle, hyprpaper, starship, GNU Stow, pacman + paru/yay (AUR).

---

## Conventions for this plan

This is a **config repo**, not an app — there are no unit tests. Each task's
"verify" step is a **command to run + what you should observe**. After each task
that changes files, **commit**. Colors come from Catppuccin Mocha; the canonical
palette is `hyprland/.config/hypr/mocha.conf` (created in Task 2).

Work happens inside `/home/abdulkhalek/dotfiles`. Configs are applied to the live
system with `stow` (symlinks into `~/.config`). Because the user's `~/.config`
dirs are already symlinks from this repo (the repo was previously stowed), most
edits take effect immediately; `hyprctl reload` re-reads Hyprland.

---

## File structure (created/modified across the plan)

```
dotfiles/
├── install.sh                         # NEW — package install + stow
├── README.md                          # NEW — what/why/how + screenshots placeholder
├── packages.txt                       # NEW — explicit dependency list
├── hyprland/.config/hypr/
│   ├── hyprland.conf                  # REWRITE — clean, commented, sources sub-files
│   ├── mocha.conf                     # MOVED here from hyprmocha/ (color vars)
│   ├── hypridle.conf                  # REWRITE — laptop idle ladder + lid
│   ├── keybinds.conf                  # NEW — all binds, grouped/commented
│   ├── autostart.conf                 # NEW — exec-once block
│   └── rules.conf                     # NEW — window/layer rules (clipse, flameshot)
├── hyprlock/.config/hypr/hyprlock.conf# KEEP/verify
├── hyprpaper/.config/hypr/hyprpaper.conf # KEEP/verify
├── ghostty/.config/ghostty/config     # POLISH
├── wofi/.config/wofi/
│   ├── config                         # NEW — drun + icons behavior
│   └── style.css                      # KEEP
├── hyprpanel/.config/hyprpanel/config.json # NEW — captured after GUI tuning
├── scripts/.local/bin/
│   ├── wallpaper-picker.sh            # NEW — wofi wallpaper switcher
│   └── power-menu.sh                  # NEW — wofi power menu
├── backgrounds/.config/backgrounds/   # KEEP
└── (DELETED) i3 picom polybar xresources screenlayout kitty alacritty
            rofi tmux hyprmocha tempCodeRunnerFile.python
```

---

### Task 1: Repo cleanup & detach from upstream

**Files:**
- Delete dirs: `i3/`, `picom/`, `polybar/`, `xresources/`, `screenlayout/`, `kitty/`, `alacritty/`, `rofi/`, `tmux/`
- Delete file: `tempCodeRunnerFile.python`
- (Note: `hyprmocha/` is deleted in Task 2 *after* its `mocha.conf` is moved.)

- [ ] **Step 1: Confirm what gets deleted (dry look)**

Run:
```bash
cd /home/abdulkhalek/dotfiles
ls -d i3 picom polybar xresources screenlayout kitty alacritty rofi tmux tempCodeRunnerFile.python
```
Expected: all listed (proves they exist before deletion).

- [ ] **Step 2: Delete X11 stack, redundant terminals/launchers, tmux, stray file**

Run:
```bash
cd /home/abdulkhalek/dotfiles
git rm -r i3 picom polybar xresources screenlayout kitty alacritty rofi tmux
git rm tempCodeRunnerFile.python
```
Expected: git reports each removal. (These were not stowed/active in the Hyprland session, so nothing on the live desktop breaks.)

- [ ] **Step 3: Detach git from upstream typecraft**

Run:
```bash
cd /home/abdulkhalek/dotfiles
git remote remove upstream
git remote -v
```
Expected: only `origin → github.com/Abdulkhalek-1/dotfiles-1.git` remains.

- [ ] **Step 4: Commit**

```bash
cd /home/abdulkhalek/dotfiles
git add -A
git commit -m "chore: remove X11 stack, redundant tools, detach upstream"
```

---

### Task 2: Make Hyprland color theme self-contained

`hyprland.conf` does `source=~/.config/hypr/mocha.conf`, but `mocha.conf` lives
in the `hyprmocha/` package we're deleting. Move it into the `hyprland/` package
so the Hyprland config is self-contained, then delete `hyprmocha/`.

**Files:**
- Create: `hyprland/.config/hypr/mocha.conf` (moved from `hyprmocha/.config/hypr/mocha.conf`)
- Delete: `hyprmocha/`

- [ ] **Step 1: Move mocha.conf into the hyprland package**

Run:
```bash
cd /home/abdulkhalek/dotfiles
git mv hyprmocha/.config/hypr/mocha.conf hyprland/.config/hypr/mocha.conf
```
Expected: file relocated under `hyprland/.config/hypr/`.

- [ ] **Step 2: Remove the now-empty hyprmocha package**

Run:
```bash
cd /home/abdulkhalek/dotfiles
git rm -r hyprmocha 2>/dev/null; rm -rf hyprmocha
ls -d hyprmocha 2>&1
```
Expected: `ls: cannot access 'hyprmocha': No such file or directory`.

- [ ] **Step 3: Re-stow hyprland and verify colors resolve**

Run:
```bash
cd /home/abdulkhalek/dotfiles
stow -R hyprland
test -f ~/.config/hypr/mocha.conf && grep -m1 mauve ~/.config/hypr/mocha.conf
```
Expected: prints the `$mauve = rgb(cba6f7)` line — proving the symlink + source path works.

- [ ] **Step 4: Reload Hyprland to confirm no broken source**

Run: `hyprctl reload`
Expected: returns `ok` with no "could not open file" error about mocha.conf.

- [ ] **Step 5: Commit**

```bash
cd /home/abdulkhalek/dotfiles
git add -A
git commit -m "refactor: move mocha.conf into hyprland package, drop hyprmocha"
```

---

### Task 3: Split Hyprland config into clean, sourced sub-files

Break the monolithic `hyprland.conf` into focused files. This is the structural
core; later tasks fill `keybinds.conf`, `autostart.conf`, `rules.conf` with the
real wiring. Here we set up the skeleton and the settings (input/laptop/visual).

**Files:**
- Rewrite: `hyprland/.config/hypr/hyprland.conf`
- Create: `hyprland/.config/hypr/autostart.conf` (stub, filled in Task 5)
- Create: `hyprland/.config/hypr/keybinds.conf` (stub, filled in Task 4)
- Create: `hyprland/.config/hypr/rules.conf` (stub, filled in Tasks 6/7)

- [ ] **Step 1: Create stub sub-files so sources resolve**

Create `hyprland/.config/hypr/autostart.conf`:
```bash
# Autostart — filled in Task 5
```
Create `hyprland/.config/hypr/keybinds.conf`:
```bash
# Keybinds — filled in Task 4
```
Create `hyprland/.config/hypr/rules.conf`:
```bash
# Window & layer rules — filled in Tasks 6/7
```

- [ ] **Step 2: Rewrite hyprland.conf**

Replace the entire contents of `hyprland/.config/hypr/hyprland.conf` with:
```bash
# ============================================================
#  Hyprland — main config (sources focused sub-files)
# ============================================================
source = ~/.config/hypr/mocha.conf
source = ~/.config/hypr/autostart.conf
source = ~/.config/hypr/keybinds.conf
source = ~/.config/hypr/rules.conf

# ---- Monitors -------------------------------------------------
monitor = eDP-1, preferred, auto, 1

# ---- Programs -------------------------------------------------
$terminal    = ghostty
$fileManager = nautilus
$browser     = xdg-open https://
$menu        = wofi --show drun
$mainMod     = SUPER

# ---- Environment ---------------------------------------------
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORMTHEME,qt5ct

xwayland {
    force_zero_scaling = true
}

# ---- Input / laptop -----------------------------------------
input {
    kb_layout  = us,eg
    kb_options = grp:alt_shift_toggle
    follow_mouse = 1
    sensitivity  = 0

    touchpad {
        natural_scroll = yes
        tap-to-click   = yes
        disable_while_typing = yes
    }
}

# 3-finger swipe to change workspaces
gestures {
    workspace_swipe = on
    workspace_swipe_fingers = 3
}

# ---- Look & feel --------------------------------------------
general {
    border_size = 3
    col.active_border   = $mauve $flamingo 90deg
    col.inactive_border = $surface0
    resize_on_border = true
    gaps_in  = 4
    gaps_out = 8
    layout   = dwindle
    allow_tearing = false
}

decoration {
    rounding = 8
    blur {
        enabled = true
        size    = 4
        passes  = 2
    }
    shadow {
        enabled = true
        range   = 4
        render_power = 3
        color   = rgba(1a1a1aee)
    }
}

animations {
    enabled = true
    bezier  = ease, 0.25, 0.1, 0.25, 1.0
    animation = windows,    1, 4, ease, slide
    animation = fade,       1, 4, ease
    animation = workspaces, 1, 5, ease, slide
    animation = border,     1, 8, ease
}

dwindle {
    preserve_split = yes
}

misc {
    force_default_wallpaper = 0
    disable_hyprland_logo   = true
}
```

- [ ] **Step 3: Stow and reload**

Run:
```bash
cd /home/abdulkhalek/dotfiles
stow -R hyprland
hyprctl reload
```
Expected: `hyprctl reload` returns `ok`, no parse errors. Borders/gaps/rounding visibly apply.

- [ ] **Step 4: Verify touchpad gesture config loaded**

Run: `hyprctl getoption gestures:workspace_swipe`
Expected: `int: 1` (enabled).

- [ ] **Step 5: Commit**

```bash
cd /home/abdulkhalek/dotfiles
git add -A
git commit -m "refactor: split hyprland.conf into sourced sub-files, tune laptop input"
```

---

### Task 4: Keybinds — clean, grouped, documented

**Files:**
- Rewrite: `hyprland/.config/hypr/keybinds.conf`

Bindings for clipse (`Super+V`), flameshot (`Print`), wallpaper picker and power
menu reference scripts created in Tasks 8/9/11/12; the binds are added now and
the targets land in those tasks.

- [ ] **Step 1: Write keybinds.conf**

Replace the entire contents of `hyprland/.config/hypr/keybinds.conf` with:
```bash
# ============================================================
#  Keybinds
# ============================================================

# ---- Apps ----------------------------------------------------
bind = $mainMod, Return, exec, $terminal
bind = $mainMod, Space,  exec, $menu
bind = $mainMod, E,      exec, $fileManager
bind = $mainMod, B,      exec, xdg-open https://
bind = $mainMod, V,      exec, ~/.local/bin/clipse-float.sh   # clipboard (Task 8)

# ---- Session / system ---------------------------------------
bind = $mainMod, L,        exec, hyprlock
bind = $mainMod, Escape,   exec, ~/.local/bin/power-menu.sh    # (Task 12)
bind = $mainMod SHIFT, R,  exec, hyprctl reload
bind = $mainMod SHIFT, W,  exec, ~/.local/bin/wallpaper-picker.sh  # (Task 11)

# ---- Window management --------------------------------------
bind = $mainMod, Q, killactive,
bind = $mainMod, F, fullscreen,
bind = $mainMod, T, togglefloating,
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,

# Focus (vim keys)
bind = $mainMod, h, movefocus, l
bind = $mainMod, l, movefocus, r
bind = $mainMod, k, movefocus, u
bind = $mainMod, j, movefocus, d

# Move windows (Shift + vim keys)
bind = $mainMod SHIFT, h, movewindow, l
bind = $mainMod SHIFT, l, movewindow, r
bind = $mainMod SHIFT, k, movewindow, u
bind = $mainMod SHIFT, j, movewindow, d

# ---- Workspaces ---------------------------------------------
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Scratchpad
bind = $mainMod, S,       togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic

# Mouse: scroll workspaces, drag to move/resize
bind  = $mainMod, mouse_down, workspace, e+1
bind  = $mainMod, mouse_up,   workspace, e-1
bindm = $mainMod, mouse:272,  movewindow
bindm = $mainMod, mouse:273,  resizewindow

# ---- Screenshots (Task 9) -----------------------------------
bind = , Print,       exec, flameshot gui
bind = SHIFT, Print,  exec, flameshot full -c

# ---- Media / brightness keys --------------------------------
bindl  = , XF86AudioPlay,  exec, playerctl play-pause
bindl  = , XF86AudioNext,  exec, playerctl next
bindl  = , XF86AudioPrev,  exec, playerctl previous
bindel = , XF86AudioRaiseVolume,  exec, pactl set-sink-volume @DEFAULT_SINK@ +5%
bindel = , XF86AudioLowerVolume,  exec, pactl set-sink-volume @DEFAULT_SINK@ -5%
bindl  = , XF86AudioMute,         exec, pactl set-sink-mute @DEFAULT_SINK@ toggle
bindl  = , XF86AudioMicMute,      exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle
bindel = , XF86MonBrightnessUp,   exec, brightnessctl set +5%
bindel = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
```

- [ ] **Step 2: Stow + reload**

Run:
```bash
cd /home/abdulkhalek/dotfiles
stow -R hyprland && hyprctl reload
```
Expected: `ok`, no errors.

- [ ] **Step 3: Verify a representative bind is registered**

Run: `hyprctl binds | grep -A2 -i 'key: 36' | head` (36 = Return)
Expected: shows a bind dispatching `exec` for the terminal. (If grep is awkward, just press `Super+Return` and confirm Ghostty opens.)

- [ ] **Step 4: Commit**

```bash
cd /home/abdulkhalek/dotfiles
git add -A
git commit -m "feat: clean grouped keybinds with media/brightness keys"
```

---

### Task 5: Autostart — HyprPanel instead of waybar/swaync

**Files:**
- Rewrite: `hyprland/.config/hypr/autostart.conf`

- [ ] **Step 1: Write autostart.conf**

Replace the entire contents of `hyprland/.config/hypr/autostart.conf` with:
```bash
# ============================================================
#  Autostart
# ============================================================
exec-once = hyprctl setcursor catppuccin-mocha-dark-cursors 28
exec-once = systemctl --user start hyprpolkitagent

# Bar + system controls + notifications (replaces waybar + swaync)
exec-once = hyprpanel

# Wallpaper, idle daemon
exec-once = hyprpaper
exec-once = hypridle

# Clipboard: persist copies after source app closes, run clipse listener
exec-once = wl-clip-persist --clipboard regular
exec-once = clipse -listen

# Network / power applets handled by HyprPanel; nothing else needed here
```

- [ ] **Step 2: Stow + reload, then start HyprPanel for this session**

Run:
```bash
cd /home/abdulkhalek/dotfiles
stow -R hyprland && hyprctl reload
pkill waybar 2>/dev/null; pkill swaync 2>/dev/null
hyprpanel &
```
Expected: the HyprPanel bar appears at the top; waybar disappears. (HyprPanel/clipse/wl-clip-persist are installed in Task 13's `install.sh`; if not yet installed, this step is re-run after Task 13.)

- [ ] **Step 3: Verify HyprPanel is running**

Run: `pgrep -a hyprpanel`
Expected: a running `hyprpanel` process is listed.

- [ ] **Step 4: Commit**

```bash
cd /home/abdulkhalek/dotfiles
git add -A
git commit -m "feat: autostart HyprPanel/clipse/wl-clip-persist, drop waybar+swaync"
```

---

### Task 6: HyprPanel configuration (capture tuned config)

HyprPanel ships a settings GUI and generates `~/.config/hyprpanel/config.json`.
Rather than hand-author its schema (brittle), tune it via the GUI, then capture
the result into the repo as a new stow package.

**Files:**
- Create: `hyprpanel/.config/hyprpanel/config.json` (captured)

- [ ] **Step 1: Open HyprPanel settings and enable laptop modules**

Run: `hyprpanel configure` (or right-click the bar → Settings)
In the GUI enable/confirm: **battery**, **power profiles**, **network (Wi-Fi)**,
**bluetooth**, **volume slider**, **brightness**, **clock**, **system tray**,
**notifications center**, and set theme to a **Catppuccin Mocha** preset.
Expected: bar updates live as you toggle modules.

- [ ] **Step 2: Capture the generated config into the repo**

Run:
```bash
cd /home/abdulkhalek/dotfiles
mkdir -p hyprpanel/.config/hyprpanel
cp ~/.config/hyprpanel/config.json hyprpanel/.config/hyprpanel/config.json
```
Expected: `config.json` now exists in the repo.

- [ ] **Step 3: Re-stow so the repo copy is the source of truth**

Run:
```bash
cd /home/abdulkhalek/dotfiles
# replace live file with a symlink to the repo copy
rm -f ~/.config/hyprpanel/config.json
stow -R hyprpanel
test -L ~/.config/hyprpanel/config.json && echo "symlinked OK"
```
Expected: prints `symlinked OK`.

- [ ] **Step 4: Verify modules present**

Run: `grep -oE '"(battery|network|bluetooth|volume)"' hyprpanel/.config/hyprpanel/config.json | sort -u`
Expected: the enabled module names appear.

- [ ] **Step 5: Commit**

```bash
cd /home/abdulkhalek/dotfiles
git add -A
git commit -m "feat: add tuned HyprPanel config (battery/network/bt/notifications)"
```

---

### Task 7: Window & layer rules (clipse + flameshot float nicely)

**Files:**
- Rewrite: `hyprland/.config/hypr/rules.conf`

- [ ] **Step 1: Write rules.conf**

Replace the entire contents of `hyprland/.config/hypr/rules.conf` with:
```bash
# ============================================================
#  Window & layer rules
# ============================================================

# Suppress maximize events apps sometimes send
windowrulev2 = suppressevent maximize, class:.*

# clipse clipboard: floating, centered, sized
windowrulev2 = float,      class:(clipse)
windowrulev2 = size 760 520, class:(clipse)
windowrulev2 = center,     class:(clipse)

# flameshot: float its GUI, no animation flicker
windowrulev2 = float,  class:(flameshot)
windowrulev2 = noblur, class:(flameshot)

# Picture-in-picture floats
windowrulev2 = float, title:(Picture-in-Picture)
windowrulev2 = pin,   title:(Picture-in-Picture)

# Smooth wofi
layerrule = noanim, wofi
```

- [ ] **Step 2: Stow + reload**

Run:
```bash
cd /home/abdulkhalek/dotfiles
stow -R hyprland && hyprctl reload
```
Expected: `ok`, no errors.

- [ ] **Step 3: Commit**

```bash
cd /home/abdulkhalek/dotfiles
git add -A
git commit -m "feat: window/layer rules for clipse, flameshot, PiP"
```

---

### Task 8: Clipboard — clipse floating launcher

`clipse` is a TUI; we open it in a floating Ghostty window (the `rules.conf`
entry from Task 7 sizes/centers it). `wl-clip-persist` (autostarted in Task 5)
keeps copied data after the source app closes; clipse persists history to disk
(`~/.config/clipse/`), so it survives reboot — meeting the spec.

**Files:**
- Create: `scripts/.local/bin/clipse-float.sh`

- [ ] **Step 1: Create the launcher script**

Create `scripts/.local/bin/clipse-float.sh`:
```bash
#!/usr/bin/env bash
# Open clipse clipboard history in a floating terminal window.
exec ghostty --class=clipse -e clipse
```

- [ ] **Step 2: Make executable and stow**

Run:
```bash
cd /home/abdulkhalek/dotfiles
chmod +x scripts/.local/bin/clipse-float.sh
stow scripts
test -x ~/.local/bin/clipse-float.sh && echo "ok"
```
Expected: prints `ok`. (Ensure `~/.local/bin` is on `PATH`; Hyprland binds use the full path so it works regardless.)

- [ ] **Step 3: Verify clipboard capture + history (after install.sh ran clipse listener)**

Run:
```bash
echo "clipboard-test-123" | wl-copy
~/.local/bin/clipse-float.sh
```
Expected: a centered floating window opens showing clipboard history including `clipboard-test-123`. Selecting an entry copies it. Press `Super+V` to confirm the bind works too.

- [ ] **Step 4: Verify history persists across the daemon restart (reboot-equivalent)**

Run:
```bash
ls ~/.config/clipse/ && cat ~/.config/clipse/clipboard_history.json 2>/dev/null | head -c 80; echo
```
Expected: a history file exists on disk (this is what survives reboot).

- [ ] **Step 5: Commit**

```bash
cd /home/abdulkhalek/dotfiles
git add -A
git commit -m "feat: clipse floating clipboard launcher (Super+V)"
```

---

### Task 9: Screenshots — flameshot on Wayland

flameshot-git works on Hyprland via the XDG portal, but the GUI sometimes needs
the portal ready. Bind is already in `keybinds.conf` (Task 4: `Print → flameshot gui`).
This task verifies it and adds a grim+swappy fallback only if flameshot fails.

**Files:**
- (Conditional) Create: `scripts/.local/bin/screenshot-fallback.sh`

- [ ] **Step 1: Verify the XDG portal for Hyprland is active**

Run: `pgrep -a xdg-desktop-portal-hyprland`
Expected: a running process. (Installed already per the environment scan.)

- [ ] **Step 2: Test flameshot region capture**

Run: `flameshot gui`
Expected: screen dims with a crosshair; you can select a region, annotate, and copy/save. Confirm `SHIFT+Print` (`flameshot full -c`) copies a full screenshot to clipboard.

- [ ] **Step 3: IF flameshot GUI fails to launch on Wayland — add fallback**

Only if Step 2 fails. Create `scripts/.local/bin/screenshot-fallback.sh`:
```bash
#!/usr/bin/env bash
# Region screenshot -> annotate (swappy) -> clipboard, Wayland-native.
grim -g "$(slurp)" - | swappy -f -
```
Then change the `Print` bind in `hyprland/.config/hypr/keybinds.conf` from
`flameshot gui` to `~/.local/bin/screenshot-fallback.sh`, add `grim slurp swappy`
to `packages.txt` (Task 13), `chmod +x`, `stow scripts`, and `hyprctl reload`.
Expected: region capture + annotate works via grim/swappy.

- [ ] **Step 4: Commit (only if files changed)**

```bash
cd /home/abdulkhalek/dotfiles
git add -A
git commit -m "feat: screenshot flow (flameshot, with grim/swappy fallback)"
```

---

### Task 10: Laptop idle/lock ladder + lid behavior

**Files:**
- Rewrite: `hyprland/.config/hypr/hypridle.conf`
- Verify: `hyprlock/.config/hypr/hyprlock.conf`

- [ ] **Step 1: Rewrite hypridle.conf with a laptop-sane ladder**

Replace the entire contents of `hyprland/.config/hypr/hypridle.conf` with:
```bash
general {
    lock_cmd       = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd  = hyprctl dispatch dpms on
}

# Dim the screen first (cheap warning)
listener {
    timeout    = 150
    on-timeout = brightnessctl -s set 10
    on-resume  = brightnessctl -r
}

# Lock the session
listener {
    timeout    = 300
    on-timeout = loginctl lock-session
}

# Turn the display off
listener {
    timeout    = 330
    on-timeout = hyprctl dispatch dpms off
    on-resume  = hyprctl dispatch dpms on
}

# Suspend to save battery
listener {
    timeout    = 900
    on-timeout = systemctl suspend
}
```

- [ ] **Step 2: Add lid-close → lock + suspend binding**

Append to `hyprland/.config/hypr/keybinds.conf`:
```bash

# ---- Laptop lid ---------------------------------------------
bindl = , switch:on:Lid Switch,  exec, loginctl lock-session
bindl = , switch:off:Lid Switch, exec, hyprctl dispatch dpms on
```

- [ ] **Step 3: Stow + restart hypridle + reload**

Run:
```bash
cd /home/abdulkhalek/dotfiles
stow -R hyprland
pkill hypridle; hypridle & hyprctl reload
```
Expected: `ok`; `pgrep hypridle` shows it running.

- [ ] **Step 4: Verify hyprlock launches**

Run: `hyprlock & sleep 1; pgrep -a hyprlock`
Expected: lock screen appears; unlock with your password. (Confirms `Super+L` and the idle lock target work.)

- [ ] **Step 5: Commit**

```bash
cd /home/abdulkhalek/dotfiles
git add -A
git commit -m "feat: laptop idle ladder (dim/lock/dpms/suspend) + lid switch"
```

---

### Task 11: Wallpaper picker (wofi)

**Files:**
- Create: `scripts/.local/bin/wallpaper-picker.sh`

- [ ] **Step 1: Create the picker script**

Create `scripts/.local/bin/wallpaper-picker.sh`:
```bash
#!/usr/bin/env bash
# Pick a wallpaper from ~/.config/backgrounds via wofi and apply with hyprpaper.
set -euo pipefail
DIR="$HOME/.config/backgrounds"

choice="$(ls -1 "$DIR" | wofi --dmenu --prompt 'Wallpaper')"
[ -z "${choice:-}" ] && exit 0
img="$DIR/$choice"

hyprctl hyprpaper preload "$img"
hyprctl hyprpaper wallpaper ",$img"

# Persist for next login
{
    echo "preload = $img"
    echo "wallpaper = ,$img"
} > "$HOME/.config/hypr/hyprpaper.conf"
```

- [ ] **Step 2: Make executable, stow, verify hyprpaper is running**

Run:
```bash
cd /home/abdulkhalek/dotfiles
chmod +x scripts/.local/bin/wallpaper-picker.sh
stow scripts
pgrep -a hyprpaper || (hyprpaper & sleep 1)
```
Expected: hyprpaper running.

- [ ] **Step 3: Test the picker**

Run: `~/.local/bin/wallpaper-picker.sh`
Expected: a wofi list of files from `~/.config/backgrounds`; selecting one changes the wallpaper immediately. Confirm `Super+Shift+W` triggers it.

> Note: this script writes `~/.config/hypr/hyprpaper.conf`, which is a symlink
> into the repo's `hyprpaper/` package — so selections are version-controlled.
> Run `cd ~/dotfiles && git status hyprpaper` after picking to see the change.

- [ ] **Step 4: Commit**

```bash
cd /home/abdulkhalek/dotfiles
git add -A
git commit -m "feat: wofi wallpaper picker (Super+Shift+W)"
```

---

### Task 12: Power menu (wofi)

**Files:**
- Create: `scripts/.local/bin/power-menu.sh`

- [ ] **Step 1: Create the power menu script**

Create `scripts/.local/bin/power-menu.sh`:
```bash
#!/usr/bin/env bash
# Wofi power menu: lock / logout / suspend / reboot / shutdown.
set -euo pipefail

options="\
 Lock\n Logout\n Suspend\n Reboot\n Shutdown"
choice="$(echo -e "$options" | wofi --dmenu --prompt 'Power' | awk '{print $2}')"

case "$choice" in
    Lock)     hyprlock ;;
    Logout)   hyprctl dispatch exit ;;
    Suspend)  systemctl suspend ;;
    Reboot)   systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
    *)        exit 0 ;;
esac
```

- [ ] **Step 2: Make executable + stow**

Run:
```bash
cd /home/abdulkhalek/dotfiles
chmod +x scripts/.local/bin/power-menu.sh
stow scripts
```
Expected: no errors.

- [ ] **Step 3: Test (choose Lock to avoid a real shutdown)**

Run: `~/.local/bin/power-menu.sh`
Expected: a wofi menu with the five options; selecting **Lock** locks the screen. Confirm `Super+Escape` opens it.

- [ ] **Step 4: Commit**

```bash
cd /home/abdulkhalek/dotfiles
git add -A
git commit -m "feat: wofi power menu (Super+Escape)"
```

---

### Task 13: Reproducible install — packages.txt + install.sh

**Files:**
- Create: `packages.txt`
- Create: `install.sh`

- [ ] **Step 1: Write packages.txt**

Create `packages.txt`:
```text
# --- Core Hyprland desktop (pacman) ---
hyprland
hyprlock
hypridle
hyprpaper
hyprpolkitagent
xdg-desktop-portal-hyprland
# --- Terminal / shell / launcher ---
ghostty
starship
wofi
# --- System / laptop tools ---
brightnessctl
playerctl
power-profiles-daemon
network-manager-applet
networkmanager
bluez
bluez-utils
blueman
# --- Clipboard / screenshots ---
wl-clipboard
wl-clip-persist
flameshot
grim
slurp
swappy
# --- Fonts / theming ---
ttf-cascadia-code-nerd
catppuccin-cursors-mocha
# --- Dotfile management ---
stow
nautilus

# --- AUR (install with paru/yay) ---
# hyprpanel-bin
# clipse
```

- [ ] **Step 2: Write install.sh**

Create `install.sh`:
```bash
#!/usr/bin/env bash
# Install packages and stow all dotfile configs.
set -euo pipefail
cd "$(dirname "$0")"

echo ">> Installing pacman packages..."
mapfile -t PKGS < <(grep -vE '^\s*#|^\s*$' packages.txt | sed '/AUR/Q')
sudo pacman -S --needed "${PKGS[@]}"

echo ">> Installing AUR packages (needs paru or yay)..."
AUR=(hyprpanel-bin clipse)
if command -v paru >/dev/null;   then paru -S --needed "${AUR[@]}"
elif command -v yay >/dev/null;  then yay  -S --needed "${AUR[@]}"
else echo "!! No AUR helper found. Install paru/yay, then: paru -S ${AUR[*]}"; fi

echo ">> Enabling services..."
sudo systemctl enable --now NetworkManager bluetooth power-profiles-daemon

echo ">> Stowing configs..."
PACKAGES=(hyprland hyprlock hyprpaper ghostty wofi starship hyprpanel scripts backgrounds nvim)
for p in "${PACKAGES[@]}"; do
    [ -d "$p" ] && stow -R "$p" && echo "   stowed $p"
done

echo ">> Done. Log into Hyprland and reload (Super+Shift+R)."
```

- [ ] **Step 3: Make executable and lint the script**

Run:
```bash
cd /home/abdulkhalek/dotfiles
chmod +x install.sh
bash -n install.sh && echo "syntax ok"
```
Expected: prints `syntax ok` (no syntax errors). Do **not** run the full install here — it's for fresh machines; this box already has the tools.

- [ ] **Step 4: Verify the AUR tools the setup depends on are actually installed now**

Run: `paru -S --needed hyprpanel-bin clipse wl-clip-persist 2>/dev/null || yay -S --needed hyprpanel-bin clipse wl-clip-persist`
Expected: `hyprpanel-bin`, `clipse`, and `wl-clip-persist` are installed (so Tasks 5/8 work live). If no AUR helper, install one first.

- [ ] **Step 5: Commit**

```bash
cd /home/abdulkhalek/dotfiles
git add -A
git commit -m "feat: packages.txt + install.sh for reproducible setup"
```

---

### Task 14: Ghostty + wofi polish

**Files:**
- Modify: `ghostty/.config/ghostty/config`
- Create: `wofi/.config/wofi/config`

- [ ] **Step 1: Polish Ghostty config**

Replace the contents of `ghostty/.config/ghostty/config` with:
```ini
theme = Catppuccin Mocha
font-family = CaskaydiaCove Nerd Font
font-size = 14
background-opacity = 0.95
gtk-titlebar = false

# Slow down mouse scrolling
mouse-scroll-multiplier = 0.95
# Fix slowness on Hyprland (ghostty#3224)
async-backend = epoll

# Quality-of-life
window-padding-x = 8
window-padding-y = 8
confirm-close-surface = false
```

- [ ] **Step 2: Create wofi config (drun + icons)**

Create `wofi/.config/wofi/config`:
```ini
show=drun
allow_images=true
image_size=28
prompt=Search
insensitive=true
width=600
height=400
lines=10
columns=1
```

- [ ] **Step 3: Stow + verify**

Run:
```bash
cd /home/abdulkhalek/dotfiles
stow -R ghostty wofi
wofi --show drun & sleep 1; pkill wofi
```
Expected: wofi opens showing app entries **with icons** (proves `allow_images`). Open a new Ghostty window to confirm font/opacity applied.

- [ ] **Step 4: Commit**

```bash
cd /home/abdulkhalek/dotfiles
git add -A
git commit -m "feat: polish ghostty + wofi (icons, padding, theme)"
```

---

### Task 15: VS Code Catppuccin theming

**Files:**
- Create: `vscode/.config/Code/User/settings.json` (only the theme-relevant keys; merge if one exists)

> VS Code stores user settings at `~/.config/Code/User/settings.json`. We add a
> small stow package so the theme is reproducible. If you already have settings,
> merge these keys rather than overwriting.

- [ ] **Step 1: Inspect any existing VS Code settings**

Run: `cat ~/.config/Code/User/settings.json 2>/dev/null || echo "none yet"`
Expected: shows current settings or `none yet`. If it exists and has content, copy it into the new file first, then add the keys below.

- [ ] **Step 2: Create the stow package settings file**

Create `vscode/.config/Code/User/settings.json` (merge with existing content if any):
```json
{
    "workbench.colorTheme": "Catppuccin Mocha",
    "editor.fontFamily": "'CaskaydiaCove Nerd Font', 'monospace', monospace",
    "editor.fontLigatures": true,
    "editor.fontSize": 14,
    "terminal.integrated.fontFamily": "CaskaydiaCove Nerd Font",
    "files.autoSave": "onFocusChange"
}
```

- [ ] **Step 3: Add the Catppuccin extension + stow**

Run:
```bash
cd /home/abdulkhalek/dotfiles
code --install-extension Catppuccin.catppuccin-vsc 2>/dev/null || echo "install extension manually: Catppuccin.catppuccin-vsc"
rm -f ~/.config/Code/User/settings.json   # only after backing up in Step 1
stow vscode
test -L ~/.config/Code/User/settings.json && echo "symlinked OK"
```
Expected: prints `symlinked OK`; VS Code switches to Catppuccin Mocha (reload window).

- [ ] **Step 4: Add vscode to install.sh stow list**

In `install.sh`, change the `PACKAGES=(...)` line to include `vscode`:
```bash
PACKAGES=(hyprland hyprlock hyprpaper ghostty wofi starship hyprpanel scripts backgrounds nvim vscode)
```

- [ ] **Step 5: Commit**

```bash
cd /home/abdulkhalek/dotfiles
git add -A
git commit -m "feat: VS Code Catppuccin Mocha theming"
```

---

### Task 16: README + final full-system verification

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write README.md**

Create `README.md`:
```markdown
# Abdulkhalek's Dotfiles

A clean, laptop-first **Hyprland** (Wayland) setup focused on development.

## Stack
| Component | Tool |
|---|---|
| Compositor | Hyprland |
| Terminal | Ghostty |
| Launcher | wofi |
| Bar + controls + notifications | HyprPanel |
| Clipboard (images, persistent) | clipse + wl-clip-persist |
| Screenshots | flameshot |
| Lock / idle | hyprlock + hypridle |
| Wallpaper | hyprpaper (+ wofi picker) |
| Shell prompt | starship |
| Theme | Catppuccin Mocha |

## Install (fresh Arch machine)
```bash
git clone https://github.com/Abdulkhalek-1/dotfiles-1.git ~/dotfiles
cd ~/dotfiles
./install.sh
```
Requires an AUR helper (`paru`/`yay`) for `hyprpanel-bin` and `clipse`.

## Layout
GNU Stow: each top-level folder mirrors `$HOME`. `stow <folder>` symlinks it.

## Key bindings (highlights)
| Bind | Action |
|---|---|
| `Super+Return` | terminal |
| `Super+Space` | launcher |
| `Super+V` | clipboard history |
| `Print` | screenshot (region) |
| `Super+L` | lock |
| `Super+Escape` | power menu |
| `Super+Shift+W` | wallpaper picker |

## Screenshots
_TODO: add screenshots._
```

- [ ] **Step 2: Full clean-stow dry run (catch symlink conflicts)**

Run:
```bash
cd /home/abdulkhalek/dotfiles
for p in hyprland hyprlock hyprpaper ghostty wofi starship hyprpanel scripts backgrounds vscode; do
    stow -n -R "$p" 2>&1 | grep -i conflict && echo "CONFLICT in $p" || true
done
echo "stow dry-run complete"
```
Expected: `stow dry-run complete` with no `CONFLICT` lines.

- [ ] **Step 3: End-to-end smoke test of the live desktop**

Manually confirm each:
- `Super+Return` → Ghostty opens (themed)
- `Super+Space` → wofi with icons
- `Super+V` → clipse floating window with history
- `Print` → flameshot region capture works
- HyprPanel bar shows battery, Wi-Fi, Bluetooth, volume, clock; notifications appear
- `Super+Shift+W` → wallpaper picker changes wallpaper
- `Super+Escape` → power menu (pick Lock)
- `hyprctl reload` → `ok`

Expected: every item passes.

- [ ] **Step 4: Confirm no leftovers from deleted stack**

Run:
```bash
cd /home/abdulkhalek/dotfiles
ls -d i3 picom polybar xresources screenlayout kitty alacritty rofi tmux hyprmocha tempCodeRunnerFile.python 2>&1 | head
```
Expected: all report "No such file or directory".

- [ ] **Step 5: Commit**

```bash
cd /home/abdulkhalek/dotfiles
git add -A
git commit -m "docs: add README; final verification of rebuilt setup"
```

---

## Self-review notes (author)

- **Spec coverage:** stack (T1–T14), laptop behavior (T3 input/gestures, T10 idle/lid, T6 power profiles in HyprPanel), keybinds (T4), repo/install/README (T1, T13, T16), clipboard images+persist (T8), screenshots flameshot (T9), HyprPanel bar+notifications (T5/T6), theming (T2, T14, T15). All spec sections mapped.
- **Ordering risk:** Tasks 5 & 8 run live tools (`hyprpanel`, `clipse`) installed in Task 13. Each such step notes it can be re-run after Task 13. If executing strictly in order, run Task 13's Step 4 (AUR install) before exercising the live verifications in 5/8 — or simply do Task 13 earlier. Subagent-driven execution should install AUR deps first if a live step fails.
- **Naming consistency:** scripts referenced in keybinds (`clipse-float.sh`, `power-menu.sh`, `wallpaper-picker.sh`) match the files created in Tasks 8/11/12. The `Super+V` bind path `~/.local/bin/clipse-float.sh` matches Task 8's stowed location.
- **No placeholders** except the intentional README "_TODO: add screenshots_" (real screenshots can only be taken by the user post-setup).