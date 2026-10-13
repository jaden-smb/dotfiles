#!/bin/bash
# Play notification sound
if [ -r "$HOME/Scripts/notification.wav" ]; then
    paplay "$HOME/Scripts/notification.wav" &
fi

# If Teams is on a different monitor than the focused one,
# also show a native Hyprland popup on the focused monitor
TEAMS_MONITOR=$(hyprctl clients -j 2>/dev/null | python3 -c "
import sys, json
for c in json.load(sys.stdin):
    if 'teams' in c.get('class','').lower():
        print(c.get('monitor',''))
        break
")

FOCUSED_MONITOR=$(hyprctl monitors -j 2>/dev/null | python3 -c "
import sys, json
for m in json.load(sys.stdin):
    if m.get('focused'):
        print(m.get('id',''))
        break
")

if [ -n "$TEAMS_MONITOR" ] && [ -n "$FOCUSED_MONITOR" ] && [ "$TEAMS_MONITOR" != "$FOCUSED_MONITOR" ]; then
    hyprctl notify 0 4000 "rgb(0070b8)" "fontsize:14  Teams notification"
fi
