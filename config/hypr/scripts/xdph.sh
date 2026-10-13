#!/bin/sh
# Manual portal recovery. Normal startup uses D-Bus activation.
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE
exec systemctl --user restart xdg-desktop-portal-hyprland.service xdg-desktop-portal.service
