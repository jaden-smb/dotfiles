#!/usr/bin/env bash
# Restart the bar gently; leave the notification daemon's history intact.
pkill -x waybar || true
waybar_log_dir="${XDG_STATE_HOME:-$HOME/.local/state}"
mkdir -p "$waybar_log_dir"
setsid -f waybar >"$waybar_log_dir/waybar.log" 2>&1 </dev/null
systemctl --user start swaync.service
