#!/usr/bin/env bash
set -euo pipefail

args=(-c -t png)
case "${1:-full}" in
    full) ;;
    region)
        geometry="$(slurp)" || exit 0
        [[ -n "$geometry" ]] || exit 0
        args+=(-g "$geometry")
        ;;
    *) printf 'Usage: screenshot.sh [full|region]\n' >&2; exit 1 ;;
esac
directory="$HOME/Pictures/Screenshots"
mkdir -p "$directory"
grim "${args[@]}" - | tee "$directory/$(date +%Y-%m-%d_%H-%M-%S_%N).png" | wl-copy
