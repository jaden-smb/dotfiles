#!/usr/bin/env bash
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$DOTFILES/.backup/$(date +%Y%m%d_%H%M%S_%N)"
TARGET_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}"
DRY_RUN=false
INSTALL_SDDM=false
usage() {
    cat <<'EOF'
Usage: bash install.sh [--dry-run] [--sddm]
  --dry-run  Show planned links, backups, and privileged writes.
  --sddm     Optionally install Silent SDDM config and user-provided assets.
             SDDM_WALLPAPER and SDDM_AVATAR may point to readable images.
EOF
}
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --sddm) INSTALL_SDDM=true ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done
say() { printf '%s\n' "$*"; }
run() { if "$DRY_RUN"; then printf 'DRY RUN: '; printf '%q ' "$@"; printf '\n'; else "$@"; fi; }
exists() { [[ -e "$1" || -L "$1" ]]; }
backup_and_link() {
    local src="$1" dst="$2" rel bak
    if [[ -L "$dst" && "$(readlink -- "$dst")" == "$src" ]]; then say "already linked: $dst"; return; fi
    if exists "$dst"; then
        rel="${dst#"$HOME/"}"
        bak="$BACKUP_DIR/${rel//\//__}"
        run mkdir -p -- "$BACKUP_DIR"
        run mv -- "$dst" "$bak"
        say "backup: $dst -> $bak"
    fi
    run mkdir -p -- "$(dirname -- "$dst")"
    run ln -s -- "$src" "$dst"
    say "link: $dst"
}
say '==> User configuration'
for src in "$DOTFILES"/config/*; do
    [[ -e "$src" ]] || continue
    backup_and_link "$src" "$TARGET_CONFIG/${src##*/}"
done
palette="$TARGET_CACHE/wal/colors-rofi-dark.rasi"
if ! exists "$palette"; then
    run mkdir -p -- "$(dirname -- "$palette")"
    run cp -- "$DOTFILES/config/rofi/palette.rasi" "$palette"
fi
for name in .zshenv .zshrc; do
    src="$DOTFILES/home/$name"
    [[ -e "$src" ]] && backup_and_link "$src" "$HOME/$name"
done
if "$INSTALL_SDDM"; then
    theme_dir=/usr/share/sddm/themes/silent
    [[ -d "$theme_dir" ]] || { say 'Install sddm-silent-theme first' >&2; exit 1; }
    wallpaper="${SDDM_WALLPAPER:-}"
    avatar="${SDDM_AVATAR:-}"
    for asset in "$wallpaper" "$avatar"; do
        [[ -z "$asset" || ( -f "$asset" && -r "$asset" ) ]] || { say "Unreadable asset: $asset" >&2; exit 1; }
    done
    say '==> Optional root-owned SDDM files'
    say "config: /etc/sddm.conf.d/90-dotfiles-theme.conf"
    say "theme config: $theme_dir/configs/default.conf"
    [[ -z "$wallpaper" ]] || say "wallpaper: $wallpaper -> $theme_dir/backgrounds/art.jpg"
    [[ -z "$avatar" ]] || say "avatar: $avatar -> /usr/share/sddm/faces/$(id -un).face.icon"
    if ! "$DRY_RUN"; then
        read -r -p 'Install these privileged SDDM files? [y/N] ' answer
        [[ "$answer" == [Yy] || "$answer" == [Yy][Ee][Ss] ]] || { say 'SDDM step skipped'; exit 0; }
    fi
    stamp="$(date +%Y%m%d_%H%M%S)"
    system_install() {
        local src="$1" dst="$2"
        if [[ -f "$dst" ]] && cmp -s -- "$src" "$dst"; then say "unchanged: $dst"; return; fi
        if exists "$dst"; then run sudo cp -a -- "$dst" "$dst.before-dotfiles-$stamp"; fi
        run sudo install -m 644 -- "$src" "$dst"
    }
    system_install "$DOTFILES/system/sddm/theme.conf" /etc/sddm.conf.d/90-dotfiles-theme.conf
    system_install "$DOTFILES/system/sddm/silent.conf" "$theme_dir/configs/default.conf"
    [[ -z "$wallpaper" ]] || system_install "$wallpaper" "$theme_dir/backgrounds/art.jpg"
    [[ -z "$avatar" ]] || system_install "$avatar" "/usr/share/sddm/faces/$(id -un).face.icon"
fi
[[ ! -d "$BACKUP_DIR" ]] || say "Backups: $BACKUP_DIR"
say 'Done.'
