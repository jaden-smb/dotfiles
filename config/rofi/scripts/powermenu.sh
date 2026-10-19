#!/bin/bash

logout=" Logout"
shutdown="⏻ Shutdown"
reboot=" Reboot"
hibernate="⏾ Hibernate"

chosen=$(printf "%s\n" "$logout" "$shutdown" "$reboot" "$hibernate" | rofi -dmenu -p "Power")

case "$chosen" in
    "$logout")  hyprctl dispatch 'hl.dsp.exit()' ;;
    "$shutdown") systemctl poweroff ;;
    "$reboot")   systemctl reboot ;;
    "$hibernate")
        if ! error=$(systemctl hibernate 2>&1); then
            notify-send -u critical "Hibernate failed" "$error"
            rofi -e "$error"
        fi
        ;;
esac
