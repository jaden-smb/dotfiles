#!/usr/bin/env bash
# Restart the bar gently; leave the notification daemon's history intact.
pkill -x waybar || true
waybar &
systemctl --user start swaync.service
