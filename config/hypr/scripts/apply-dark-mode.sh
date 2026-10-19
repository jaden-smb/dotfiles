#!/bin/sh
# Native persistent desktop preferences, using the real graphical session bus.
# Keep icons consistent with the installed theme without changing fonts or cursors.
set -eu
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'

# Some dconf failures only produce warnings, so verify the committed values.
for entry in 'color-scheme prefer-dark' 'gtk-theme Adwaita-dark' 'icon-theme Adwaita'; do
    key=${entry%% *}
    expected=${entry#* }
    actual=$(gsettings get org.gnome.desktop.interface "$key")
    if [ "$actual" != "'$expected'" ]; then
        printf 'Could not persist %s; run this script in the graphical session.\n' "$key" >&2
        exit 1
    fi
done
