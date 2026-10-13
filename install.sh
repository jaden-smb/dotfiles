#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$DOTFILES/config"
HOME_DIR="$DOTFILES/home"
BACKUP_DIR="$DOTFILES/.backup/$(date +%Y%m%d_%H%M%S_%N)"
TARGET_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[+]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
skipped() { echo -e "[-] $*"; }

backup_and_link() {
    local src="$1"
    local dst="$2"

    # Already correctly linked — nothing to do
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        skipped "already linked: $dst"
        return
    fi

    # Back up whatever is there
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        local rel="${dst#"$HOME/"}"
        local bak="$BACKUP_DIR/${rel//\//__}"
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$bak"
        warn "backed up: $dst -> $bak"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    info "linked: $dst"
}

# ── ~/.config entries ────────────────────────────────────────────────────────

mkdir -p "$TARGET_CONFIG"

# Link the entries actually present, including future configuration directories.
echo ""
echo "==> Linking config entries"
for src in "$CONFIG_DIR"/*; do
    [ -e "$src" ] || continue
    backup_and_link "$src" "$TARGET_CONFIG/${src##*/}"
done

# Rofi can start before the first wallpaper palette is generated.
# Never overwrite an existing palette during installation.
mkdir -p "$TARGET_CACHE/wal"
if [ ! -e "$TARGET_CACHE/wal/colors-rofi-dark.rasi" ]; then
    cp "$CONFIG_DIR/rofi/palette.rasi" "$TARGET_CACHE/wal/colors-rofi-dark.rasi"
fi

# ── Home dotfiles ────────────────────────────────────────────────────────────

HOME_FILES=(
    .zshenv
    .zshrc
)

echo ""
echo "==> Linking home dotfiles"
for f in "${HOME_FILES[@]}"; do
    src="$HOME_DIR/$f"
    if [ ! -e "$src" ]; then
        warn "not found in dotfiles, skipping: $f"
        continue
    fi
    backup_and_link "$src" "$HOME/$f"
done

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
if [ -d "$BACKUP_DIR" ]; then
    info "Backups saved to: $BACKUP_DIR"
fi
info "All done. You may need to restart your shell or reload configs."
