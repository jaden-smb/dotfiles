# dotfiles

Personal configuration files for my Hyprland desktop on Arch Linux.

## Stack

| Role | Tool |
|---|---|
| Compositor | [Hyprland](https://hyprland.org) |
| Terminal | [Ghostty](https://ghostty.org/) |
| Shell | Zsh + Powerlevel10k |
| Bar | [Waybar](https://github.com/Alexays/Waybar) |
| Launcher | [Rofi](https://github.com/davatorium/rofi) / [Wofi](https://hg.sr.ht/~scoopta/wofi) |
| Logout menu | [Wlogout](https://github.com/ArtsyMacaw/wlogout) |
| Notifications | [Swaync](https://github.com/ErikReider/SwayNotificationCenter) |
| File manager | Thunar |
| Editor | Neovim |
| GTK theme | via `nwg-look` |
| Wallpaper | [awww](https://codeberg.org/LGFae/awww) |
| Palette | [pywal16](https://github.com/eylles/pywal16) |
| Lock screen | [Hyprlock](https://wiki.hypr.land/Hypr-Ecosystem/hyprlock/) |
| System information | [Fastfetch](https://github.com/fastfetch-cli/fastfetch) |

## Install

Clone the repo anywhere and run the installer:

```bash
git clone https://github.com/jaden-smb/dotfiles.git
cd dotfiles
bash install.sh --dry-run
bash install.sh
```

`install.sh` will:

- Create a timestamped backup of any existing file it would overwrite (saved to `.backup/`)
- Symlink every entry from `config/` into `$XDG_CONFIG_HOME` (defaults to `~/.config/`)
- Symlink `home/.zshenv` and `home/.zshrc` into `~/`

To re-run safely at any time — already-correct symlinks are skipped.
The dry run does not write files. Review the entries before a first install:
`gtk-3.0/bookmarks`, monitor names, and MIME defaults reflect this machine.

This configuration was inspected on **Arch Linux** with **Hyprland 0.56.2-4**
and uses `config/hypr/hyprland.lua`. Verify that the installed Hyprland
supports this Lua configuration before starting a new session.
The installer links files; it does not install or upgrade packages. See the
[upstream releases](https://github.com/hyprwm/Hyprland/releases) and
[Lua configuration documentation](https://wiki.hypr.land/configuring/core/).

After installing, restart your Hyprland session to load the Lua config and apply
environment variables and permissions. Check `hyprctl configerrors` after login.
Later edits can be applied with `hyprctl reload`.

### Dependencies

Use current packages from your distribution for these components:

| Component | Required commands / packages |
|---|---|
| Desktop | Hyprland, Hyprlock, hyprpolkitagent, xdg-desktop-portal-hyprland, xdg-desktop-portal |
| Bar and notifications | Waybar, Swaync, PipeWire, WirePlumber (`wpctl`) |
| Wallpaper and picker | `awww`, `awww-daemon`, ImageMagick 7 (`magick`), Wofi, pywal16 (`wal`), util-linux (`flock`) |
| Launchers and apps | Rofi with Wayland support, Ghostty, Thunar, Wlogout, Fcitx5, Kitty/Alacritty (optional) |
| Current file defaults | Chromium, imv, Okular, VLC, LibreOffice Writer and Calc |
| Screenshots and controls | `grim`, `slurp`, `wl-copy`, `brightnessctl`, `playerctl`, `jq` |
| Shell | Zsh, Oh My Zsh, Powerlevel10k, `eza`, `zoxide`, Fastfetch |
| Thunar archive action | `libarchive` (`bsdtar`), `zenity`, Python 3 |

Install **awww** using your distribution's package if available, or follow its
[upstream build instructions](https://codeberg.org/LGFae/awww#build). Both the
client and daemon must be in `PATH`. It replaces the archived `swww` project.
For the palette generator, the upstream-supported pipx installation is:

```bash
sudo pacman -Syu imagemagick wofi rofi python-pipx
pipx install pywal16
pipx ensurepath
```

See [pywal16 installation](https://github.com/eylles/pywal16/wiki/Installation).
If pywal16 is already installed with pipx, use `pipx upgrade pywal16` instead.
The wallpaper script includes `~/.local/bin` in its search path.

Fonts and icons remain personal choices: install MesloLGS NF for the terminals,
Lexend/JetBrains Mono Nerd Font for Waybar, and the configured GTK/Qt icon themes.
The Hyprlock font and optional profile image can be changed in `hyprlock.conf`.
For multilingual fallback, install the official Arch packages `noto-fonts`,
`noto-fonts-cjk`, and `noto-fonts-emoji`. Waybar's icon glyphs use
`ttf-jetbrains-mono-nerd`. Install these on a fresh Arch setup with:

```bash
sudo pacman -S --needed noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono-nerd
```

The installer only links configuration; it does not install packages. Check
coverage with `python tests/check_font_coverage.py` and inspect the sample in
`tests/typography.txt` in a browser, terminal, and desktop applications.

### Updated integrations

- The live Lua configuration leaves graphics driver selection to the installed
  drivers and requests automatic hardware cursor behavior.
- Portal services use D-Bus activation after the Wayland environment is imported.
  `config/hypr/scripts/xdph.sh` is a manual systemd portal recovery command.
- Waybar currently has no Cava or MPRIS module in its active module lists.
  It has separate bars for eDP-1 and HDMI-A-1, shows SwayNC notification status, detects the active network interface,
  and uses PipeWire-compatible audio. SwayNC uses a 480 px control center and
  notification window with its current dark theme.
- Hyprlock captures and blurs the desktop directly; Super+L no longer requires an
  untracked lock-screen script. Wlogout uses the same locker.
- Zsh loads the shared `aliasrc`, uses `eza`, creates its history directory, and
  skips optional tools that are absent. Fastfetch replaces the Neofetch config.
- The installer discovers the configs present in the repository and seeds a
  fallback Rofi palette without overwriting an existing generated palette.
  GTK, Qt, Hyprpanel, and the existing desktop themes remain available; Hyprpanel
  is an alternative to the Waybar/Swaync combination started by this config.
- Chromium uses a native Wayland flag. Zed uses the VS Code keymap, Gruvbox
  light/dark themes, and disabled telemetry. Thunar has a custom archive action
  backed by `config/Thunar/scripts/thunar-compress`.

## Wallpapers

### Set your first wallpaper

Run the installer first so the tracked pywal templates are linked. Put JPG, JPEG,
PNG, or WebP files in `~/Pictures/Wallpapers`, including subdirectories if desired:

```bash
mkdir -p "$HOME/Pictures/Wallpapers"
cp "/path/to/your-image.jpg" "$HOME/Pictures/Wallpapers/default.jpg"
bash "$HOME/.config/hypr/scripts/wallpaper.sh" "$HOME/Pictures/Wallpapers/default.jpg"
```

Run that last command **inside a running Hyprland session**. It starts `awww-daemon`
if needed, applies the image to all outputs, generates the palette with
`wal --cols16 -n -e -q`, reloads Hyprland, and refreshes running Kitty windows. The command
saves the selected absolute path only after the image has been applied.

### Choose or randomize a wallpaper

Press **Super+A** to open the Wofi thumbnail picker. Select an image, or select
**Random wallpaper**. Escape closes the picker without changing the selection.
You can also use the commands directly:

```bash
# Apply a specific image; spaces in paths are supported.
bash "$HOME/.config/hypr/scripts/wallpaper.sh" "$HOME/Pictures/Wallpapers/my wallpaper.png"

# Choose a random image from the wallpaper directory.
bash "$HOME/.config/hypr/scripts/wallpaper.sh" --random

# Open the thumbnail picker.
bash "$HOME/.config/hypr/scripts/wofi-wallpaper-selector.sh"
```

To use a different image directory for a command:

```bash
WALLPAPER_DIR="$HOME/Other Wallpapers" bash "$HOME/.config/hypr/scripts/wofi-wallpaper-selector.sh"
```

For a permanent directory change, set `hl.env("WALLPAPER_DIR", "/absolute/path")`
in `hyprland.lua` and restart the session.

### Persistence and colors

Hyprland calls `wallpaper.sh --restore` at login. It restores the path saved in
`~/.local/state/hypr/wallpaper` (`$XDG_STATE_HOME/hypr/wallpaper` when set). If no
selection exists, it tries `~/Pictures/Wallpapers/default.jpg`. Keep the selected
image in place; moving or deleting it prevents restoration.

The desktop wallpaper is handled by **awww**. Pywal16 generates palettes in
`~/.cache/wal`, including the tracked templates for Hyprland borders and Rofi.
Kitty and Alacritty read the generated terminal palettes. The bar and notification
center keep their existing themes. The Lua color loader uses fallback border
colors if no palette exists. [Pywal template documentation](https://github.com/eylles/pywal16/wiki/User-Template-Files).

The scripts honor `XDG_CACHE_HOME` and `XDG_STATE_HOME`. Rofi and terminal imports
use `~/.cache/wal` by default; update their import paths if you relocate the palette
cache. If you clear that cache or edit a template, run `wallpaper.sh IMAGE` again
with your selected image to regenerate the palettes. Wallpaper state is kept
outside the cache, and restoration does not regenerate colors on every login.

Hyprlock uses a blurred screenshot of the current desktop. Changing a desktop
wallpaper does not modify SDDM. The old `sddm_rEFInd_bg.sh` helper is retained
only as historical configuration; its Sugar Candy and rEFInd paths do not
represent the current login screen.

### Check the setup

```bash
awww query
hyprctl configerrors
cat "${XDG_STATE_HOME:-$HOME/.local/state}/hypr/wallpaper"
```

If daemon startup fails, inspect `${XDG_CACHE_HOME:-$HOME/.cache}/awww.log`.
Stop an old `swww-daemon` or another wallpaper service if it is still started by
an older user service or autostart entry. `hyprctl reload` updates settings;
use `wallpaper.sh` to change the wallpaper.

After connecting another physical monitor, reapply the saved image with:

```bash
bash "$HOME/.config/hypr/scripts/wallpaper.sh" --restore
```

The virtual tablet monitor script does this automatically.

## Structure

```
dotfiles/
├── install.sh
├── config/          # mirrors ~/.config
│   ├── hypr/        # Hyprland Lua config + Hyprlock + scripts
│   ├── ghostty/     # default terminal: cool blue palette, 95% opacity
│   ├── kitty/       # optional terminal
│   ├── waybar/      # status bar
│   ├── rofi/        # app launcher
│   ├── wofi/        # wallpaper picker launcher
│   ├── wlogout/     # logout screen
│   ├── swaync/      # notification center
│   ├── wal/         # tracked palette templates
│   ├── fastfetch/   # system information
│   ├── Thunar/      # archive action and helper
│   ├── zed/         # editor preferences
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

`main_mod` = **Super** (Windows key), defined in `config/hypr/keywords/keywords.lua`.

### Applications

| Keybind | Action |
|---|---|
| Super + Q | Open terminal (Ghostty) |
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
| Super + Shift + B | Connect / disconnect the virtual tablet monitor |

## Notes

- `config/gh/hosts.yml` is excluded (contains local account info). Re-authenticate with `gh auth login` after a fresh install.
- Zsh uses `ZDOTDIR=~/.config/zsh` — the real config lives in `config/zsh/`, not `~/`.
- The live default browser is Chromium. The current MIME defaults open images
  with imv, PDFs with Okular, and videos with VLC. The browser picker still
  offers Brave and other installed browsers; the YouTube Music shortcut,
  Bluetooth manager, and network TUI need their respective optional apps.
  `walker` is named in `keywords.lua` but is not installed or called by the
  active Super+D binding.
- Ghostty reads `config.ghostty` from its linked config directory. Its cool blue
  palette keeps the TokyoNight text color, with a 95% opaque background and
  opaque text cell backgrounds.
- The Lua config specifies eDP-1 and HDMI-A-1 and US/Latin American keyboard
  layouts. Adapt these to the new machine before logging in. Its optional
  `~/Scripts/battery-checknow` hook runs only if present.
- The desktop starts Waybar, Swaync, Hypridle, Fcitx5, the polkit agent, and
  the wallpaper restore from the Hyprland startup callback. PipeWire,
  WirePlumber, network and portal services rely on the installed system/user
  service setup. The service bus was unavailable to this audit, so enabled
  state was not verified.
- The current GTK 3 and GTK 4 settings request dark Adwaita and Adwaita icons;
  the startup script also persists the GNOME color-scheme preference.
  Three old GTK 4 links to the absent `adw-gtk3-dark` theme were removed.
  The optional Qt5/Qt6 configs still refer to `Papirus-Dark-Maia`, which was
  not installed in this audit and is not selected by the current
  `QT_QPA_PLATFORMTHEME=gtk3` setting.
- Neovim is maintained separately at `~/.config/nvim` in the `nvim-config`
  repository. `install.sh` does not link or replace it.

### Power and lid settings

The current system uses `system/zram/zram-generator.conf` to create a zstd zram
swap device sized to half of RAM. `/etc/systemd/logind.conf.d/10-ac-awake.conf`
keeps the lid close action from suspending the laptop while on external power.
These root-owned files are captured in the repo but are not installed by
`install.sh`. Review them before copying to `/etc/systemd/` on a new machine.
The hibernation setup below is a separate, machine-dependent procedure.

### SDDM Silent

The current SDDM selects Silent through `/etc/sddm.conf.d/theme.conf`.
Silent's `metadata.desktop` selects `configs/default.conf`, which names
`art.jpg` for both lock and login backgrounds. The current image lives under
`/usr/share/sddm/themes/silent/backgrounds/`; the avatar lives at
`/usr/share/sddm/faces/jaden.face.icon`. Neither image is committed.
`system/sddm/theme.conf` and `system/sddm/silent.conf` capture the verified
text settings. The theme config is package-owned and may be overwritten by
updates.

After installing `sddm`, the AUR package `sddm-silent-theme`, and
`qt6-virtualkeyboard`, review the optional privileged step:

```bash
SDDM_WALLPAPER=/path/to/image.jpg SDDM_AVATAR=/path/to/avatar.png bash install.sh --dry-run --sddm
SDDM_WALLPAPER=/path/to/image.jpg SDDM_AVATAR=/path/to/avatar.png bash install.sh --sddm
```

It asks for confirmation, backs up differing destinations beside the original,
and installs only supplied images. Omit either variable to leave that asset
alone. On a fresh install, supply `SDDM_WALLPAPER` or change both
`background` entries in `system/sddm/silent.conf` to a theme image that
exists there. Check that `metadata.desktop` still selects `configs/default.conf`
after a theme update. The old `sddm_rEFInd_bg.sh` helper targets Sugar Candy
and rEFInd paths and does not apply to this setup. No SDDM restart is performed.

### Hibernation

This machine uses an 8 GiB `/swap-hibernate` file on ext4, alongside zram.
GRUB has a resume device and offset, and `/etc/fstab` mounts the swap file.
`system/hibernation/setup-hibernation.sh` captures the guarded setup procedure;
it calculates the resume values for the machine where it runs. The installer
does not run it. Review the script and use it only on an ext4 root with GRUB
and the systemd initramfs hook.

### Fresh install checklist

1. Install the desktop, portal, audio, font, launcher, lock, bar, notification,
   screenshot, wallpaper, shell, and optional app packages listed above. On
   this machine, `blueman`, `networkmanager`, and `power-profiles-daemon`
   supply active Waybar actions; Chromium supplies the MIME browser.
2. Clone the repository, review monitor names and personal paths, run
   `bash install.sh --dry-run`, then `bash install.sh`.
3. Supply your own desktop image under `~/Pictures/Wallpapers` and run
   `wallpaper.sh IMAGE` from a Hyprland session. Set an avatar and SDDM image
   separately using the optional step above.
4. Verify `hyprctl configerrors`, `gsettings get org.gnome.desktop.interface
   color-scheme`, `xdg-mime query default text/html`, `awww query`,
   `systemctl --user status pipewire wireplumber swaync hypridle`, and the
   installed portals after login. Check SDDM at the next login without
   restarting it during an active session.

## Validation

Run the isolated regression checks with Python 3.11 or newer:

```bash
python3 -m unittest discover -s tests -v
```

They use temporary home directories and fake desktop commands to check installer
backups, repeat installation, wallpaper persistence/failures, picker cancellation,
and config syntax. With a Lua 5.4 library installed, the suite also loads the Lua
modules against a simulated Hyprland API. These checks do not replace checking
`hyprctl configerrors`, locking the session, and testing the bar on the actual desktop.
