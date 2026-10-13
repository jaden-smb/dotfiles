#!/usr/bin/env bash
set -euo pipefail

wallpaper_dir="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-selector"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

for tool in wofi magick sha256sum; do
    command -v "$tool" >/dev/null || { printf 'Wallpaper picker: missing %s\n' "$tool" >&2; exit 1; }
done
[[ -d "$wallpaper_dir" ]] || { printf 'Add images to %s first.\n' "$wallpaper_dir" >&2; exit 1; }
mapfile -d '' -t images < <(find "$wallpaper_dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -print0 | sort -z)
((${#images[@]})) || { printf 'No wallpapers in %s\n' "$wallpaper_dir" >&2; exit 1; }
mkdir -p "$cache_dir"
entries=('Random wallpaper')
choices=('')
for image in "${images[@]}"; do
    # The menu is line-based; don't misinterpret unusual names as extra entries.
    [[ "$image" != *$'\n'* ]] || continue
    hash="$(printf '%s' "$image" | sha256sum)"
    thumbnail="$cache_dir/${hash%% *}.png"
    if [[ ! -f "$thumbnail" || "$image" -nt "$thumbnail" ]]; then
        magick "${image}[0]" -thumbnail '250x141^' -gravity center -extent 250x141 "$thumbnail" || continue
    fi
    entries+=("img:$thumbnail:text:${image#"$wallpaper_dir"/}")
    choices+=("$image")
done
# A line number maps directly to the original file, even with duplicate basenames.
if ! selected=$(printf '%s\n' "${entries[@]}" | wofi --dmenu --allow-images --no-custom-entry \
    --define=dmenu-print_line_num=true --cache-file=/dev/null --sort-order=default \
    --conf="$config_dir/wofi/wallpaper.conf" --style="$config_dir/wofi/wallpaper.css"); then
    exit 0
fi
[[ "$selected" =~ ^[0-9]+$ ]] || exit 0
index=$((10#$selected))
((index < ${#choices[@]})) || exit 1
if ((index == 0)); then
    exec bash "$script_dir/wallpaper.sh" --random
fi
exec bash "$script_dir/wallpaper.sh" "${choices[index]}"
