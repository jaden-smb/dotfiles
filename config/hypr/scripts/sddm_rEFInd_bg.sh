#!/usr/bin/env bash

set -euo pipefail
[[ $# == 2 ]] || { printf 'Usage: %s IMAGE BLURRED_IMAGE\n' "$0" >&2; exit 1; }
# Optional helper for this machine's installed login and boot themes.
install -m 644 -- "$1" /usr/share/sddm/themes/sugar-candy/wallpaper.jpg
install -m 644 -- "$2" /boot/efi/EFI/refind/themes/jsfsf-rEFInd/bg.png
