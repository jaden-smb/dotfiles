#!/bin/sh

# List of web browsers with their launch commands
browsers="Brave Web Browser
Brave Web Browser (nightly)
Firefox
Tor Browser
Chromium"

# Show the browsers in Rofi and get the selected browser
selected=$(printf "%s\n" "$browsers" | rofi -dmenu -p "Choose browser")

# Launch the selected browser
case "$selected" in
    "Brave Web Browser")
        brave --ozone-platform=wayland --enable-wayland-ime &
        ;;
      "Brave Web Browser (nightly)")
        brave-nightly --ozone-platform=wayland --enable-wayland-ime &
        ;;
    Firefox)
        firefox &
        ;;
    "Tor Browser")
        torbrowser-launcher &
        ;;
    Chromium)
        chromium --ozone-platform=wayland --enable-wayland-ime &
        ;;
    *)
        printf "No browser selected or unknown choice.\n"
        ;;
esac
