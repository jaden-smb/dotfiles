# dotfiles

Personal configuration files for my Hyprland desktop on Manjaro Linux.

## Stack

| Role | Tool |
|---|---|
| Compositor | [Hyprland](https://hyprland.org) |
| Terminal | [Kitty](https://sw.kovidgoyal.net/kitty/) |
| Shell | Zsh + Powerlevel10k |
| Bar | [Waybar](https://github.com/Alexays/Waybar) |
| Launcher | [Rofi](https://github.com/davatorium/rofi) / [Wofi](https://hg.sr.ht/~scoopta/wofi) |
| Logout menu | [Wlogout](https://github.com/ArtsyMacaw/wlogout) |
| Notifications | [Swaync](https://github.com/ErikReider/SwayNotificationCenter) |
| File manager | Thunar |
| Editor | Neovim |
| GTK theme | via `nwg-look` |

## Install

Clone the repo anywhere and run the installer:

```bash
git clone https://github.com/jaden-smb/dotfiles.git
cd dotfiles
bash install.sh
```

`install.sh` will:
- Create a timestamped backup of any existing file it would overwrite (saved to `.backup/`)
- Symlink every entry from `config/` into `~/.config/`
- Symlink `home/.zshenv` and `home/.zshrc` into `~/`

To re-run safely at any time — already-correct symlinks are skipped.

## Structure

```
dotfiles/
├── install.sh
├── config/          # mirrors ~/.config
│   ├── hypr/        # Hyprland compositor + keybinds + scripts
│   ├── kitty/       # terminal
│   ├── waybar/      # status bar
│   ├── rofi/        # app launcher
│   ├── wofi/        # wallpaper picker launcher
│   ├── wlogout/     # logout screen
│   ├── swaync/      # notification center
│   ├── nvim/        # Neovim
│   ├── zsh/         # Zsh config (ZDOTDIR)
│   ├── alacritty/   # secondary terminal
│   ├── gtk-3.0/
│   ├── gtk-4.0/
│   └── …
└── home/            # files that live directly in ~/
    ├── .zshenv      # sets ZDOTDIR=~/.config/zsh
    └── .zshrc
```

## Hyprland keybindings

`$mainMod` = **Super** (Windows key)

### Applications

| Keybind | Action |
|---|---|
| Super + Q | Open terminal (Kitty) |
| Super + E | Open file manager (Thunar) |
| Super + D | App launcher (Rofi drun) |
| Super + R | Command runner (Rofi run) |
| Super + W | Browser picker (Rofi) |
| Super + A | Wallpaper selector (Wofi) |
| Super + M | Logout screen (Wlogout) |
| Super + Shift + M | YouTube Music |
| Super + L | Lock screen |

### Window management

| Keybind | Action |
|---|---|
| Super + C | Close active window |
| Super + V | Toggle floating |
| Super + F | Toggle fullscreen |
| Super + P | Toggle pseudo-tiling (dwindle) |
| Super + J | Toggle split direction (dwindle) |

### Focus

| Keybind | Action |
|---|---|
| Super + Arrow keys | Move focus (left / right / up / down) |

### Workspaces

| Keybind | Action |
|---|---|
| Super + 1–0 | Switch to workspace 1–10 |
| Super + Shift + 1–0 | Move active window to workspace 1–10 |
| Super + S | Toggle scratchpad workspace |
| Super + Shift + S | Move window to scratchpad |
| Super + Scroll up/down | Cycle through workspaces |

### Mouse

| Keybind | Action |
|---|---|
| Super + Left click + drag | Move window |
| Super + Right click + drag | Resize window |

### Screenshots

| Keybind | Action |
|---|---|
| Print | Full-screen screenshot → `~/Pictures/Screenshots/` + clipboard |
| Super + B | Region screenshot → `~/Pictures/Screenshots/` + clipboard |

### Media & hardware keys

| Key | Action |
|---|---|
| XF86AudioRaiseVolume | Volume +5% |
| XF86AudioLowerVolume | Volume -5% |
| XF86AudioMute | Toggle mute |
| XF86AudioMicMute | Toggle mic mute |
| XF86MonBrightnessUp | Brightness +5% |
| XF86MonBrightnessDown | Brightness -5% |
| XF86AudioNext | Next track |
| XF86AudioPrev | Previous track |
| XF86AudioPlay/Pause | Play / Pause |

### Monitors

| Keybind | Action |
|---|---|
| Super + Shift + B | Toggle / reconfigure monitors |

## Notes

- Hyprland fonts (`config/hypr/Fonts/`) are excluded from the repo due to size — install your preferred fonts separately.
- `config/gh/hosts.yml` is excluded (contains local account info). Re-authenticate with `gh auth login` after a fresh install.
- Wallpapers are managed at runtime via the Wofi wallpaper selector script (`config/hypr/scripts/wofi-wallpaper-selector.sh`).
- Zsh uses `ZDOTDIR=~/.config/zsh` — the real config lives in `config/zsh/`, not `~/`.
