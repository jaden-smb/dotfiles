#!/usr/bin/env bash
# Restart the bar gently; leave the notification daemon's history intact.
pkill -x waybar || true
waybar &
pgrep -x swaync >/dev/null || swaync &
