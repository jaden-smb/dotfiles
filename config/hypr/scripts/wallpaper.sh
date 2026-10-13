#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"

# One entry point for manual selection, the picker, and session restoration.
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
wallpaper_dir="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
state_file="$state_dir/wallpaper"
restore=false

fail() { printf 'Wallpaper: %s\n' "$*" >&2; exit 1; }
if [[ $# != 1 ]]; then
    fail 'Usage: wallpaper.sh IMAGE | --random | --restore'
fi
case "$1" in
    --restore)
        restore=true
        image="$wallpaper_dir/default.jpg"
        if [[ -r "$state_file" ]]; then IFS= read -r image < "$state_file"; fi
        ;;
    --random)
        [[ -d "$wallpaper_dir" ]] || fail "Directory not found: $wallpaper_dir"
        mapfile -d '' -t images < <(find "$wallpaper_dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -print0)
        ((${#images[@]})) || fail "No images in $wallpaper_dir"
        image="${images[RANDOM % ${#images[@]}]}"
        ;;
    --*) fail "Unknown option: $1" ;;
    *) image="$1" ;;
esac

command -v awww >/dev/null || fail 'Install awww and awww-daemon first.'
mkdir -p "$cache_dir" "$state_dir"
# Serialize startup and picker requests to avoid duplicate daemons or palettes.
exec 9> "$state_dir/wallpaper.lock"
flock -w 10 9 || fail 'Another wallpaper request is still running.'
if ! awww query >/dev/null 2>&1; then
    command -v awww-daemon >/dev/null || fail 'awww-daemon is missing.'
    # Close our lock FD in the child; the persistent daemon must not hold it.
    awww-daemon 9>&- >> "$cache_dir/awww.log" 2>&1 &
    ready=false
    for ((attempt=0; attempt<50; attempt++)); do
        if awww query >/dev/null 2>&1; then ready=true; break; fi
        sleep 0.1
    done
    "$ready" || fail "Daemon did not start; see $cache_dir/awww.log"
fi

if [[ ! -f "$image" || ! -r "$image" ]]; then
    if "$restore"; then
        printf 'Wallpaper: select an image with Super+A or wallpaper.sh IMAGE.\n' >&2
        exit 0
    fi
    fail "Image not readable: $image"
fi
image="$(realpath -- "$image")"
[[ "$image" != *$'\n'* ]] || fail 'Image paths containing newlines are not supported.'

if ! "$restore"; then
    command -v wal >/dev/null || fail 'Install pywal16 (the wal command) first.'
    # awww owns the wallpaper; wal generates colors without setting the background
    # or restarting unrelated applications.
    wal --cols16 -n -e -q -i "$image"
fi
awww img "$image" --transition-type any --transition-fps 60 --transition-duration 0.8

if ! "$restore"; then
    # Persist only after applying the image successfully. State survives cache cleanup.
    state_tmp="$(mktemp "$state_dir/.wallpaper.XXXXXX")"
    trap 'rm -f -- "$state_tmp"' EXIT
    printf '%s\n' "$image" > "$state_tmp"
    mv -- "$state_tmp" "$state_file"
    hyprctl reload
    # Kitty supports live config reloading; other clients read the generated palette.
    if command -v pgrep >/dev/null; then pkill -USR1 -x kitty || true; fi
fi
