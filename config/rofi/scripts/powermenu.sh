#!/bin/bash

logout=" Logout"
shutdown="⏻ Shutdown"
reboot=" Reboot"

chosen=$(printf "%s\n%s\n%s" "$logout" "$shutdown" "$reboot" | rofi -dmenu -p "Power")

case "$chosen" in
    "$logout")  hyprctl dispatch exit ;;
    "$shutdown") systemctl poweroff ;;
    "$reboot")   systemctl reboot ;;
esac
