-- Hyprland 0.56.2+ Lua configuration.
-- https://wiki.hypr.land/configuring/core/
local colors = require("colors")

-- Display layout and workspace assignments.
hl.monitor({ output = "eDP-1", mode = "1920x1080@60.06", position = "0x0", scale = 1.33 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60.00", position = "1444x0", scale = "auto" })
for workspace = 1, 9 do
    hl.workspace_rule({
        workspace = tostring(workspace),
        monitor = workspace <= 3 and "eDP-1" or "HDMI-A-1",
        default = workspace == 1 or workspace == 4,
    })
end

-- Wayland toolkit environment. NVIDIA variables follow the current wiki.
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- These permissions take effect after restarting Hyprland.
hl.permission({ binary = "/usr/(bin|local/bin)/grim", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/(bin|local/bin)/hyprpm", type = "plugin", mode = "allow" })

hl.config({ ["ecosystem.no_update_news"] = true })

-- Appearance, layout and input settings.
hl.config({
    ["general.gaps_in"] = 5,
    ["general.gaps_out"] = 20,
    ["general.border_size"] = 2,
    ["general.col.active_border"] = colors.active_border,
    ["general.col.inactive_border"] = colors.inactive_border,
    ["general.resize_on_border"] = false,
    ["general.allow_tearing"] = false,
    ["general.layout"] = "dwindle",
})

hl.config({
    ["decoration.rounding"] = 10,
    ["decoration.rounding_power"] = 2,
    ["decoration.active_opacity"] = 1.0,
    ["decoration.inactive_opacity"] = 1.0,
    ["decoration.shadow.enabled"] = true,
    ["decoration.shadow.range"] = 4,
    ["decoration.shadow.render_power"] = 3,
    ["decoration.shadow.color"] = "rgba(1a1a1aee)",
    ["decoration.blur.enabled"] = true,
    ["decoration.blur.size"] = 10,
    ["decoration.blur.passes"] = 3,
    ["decoration.blur.ignore_opacity"] = true,
    ["decoration.blur.noise"] = 0.08,
    ["decoration.blur.contrast"] = 1.5,
    ["decoration.blur.xray"] = false,
    ["decoration.blur.new_optimizations"] = true,
    ["decoration.blur.vibrancy"] = 0.1696,
})

hl.config({
    ["dwindle.preserve_split"] = true,
})

hl.config({
    ["master.new_status"] = "master",
})

hl.config({
    ["misc.force_default_wallpaper"] = 0,
    ["misc.disable_hyprland_logo"] = true,
})

hl.config({
    ["cursor.inactive_timeout"] = 0,
    ["cursor.hide_on_touch"] = false,
    ["cursor.no_hardware_cursors"] = 2, -- Automatic, rather than forcing software cursors.
})

hl.config({
    ["input.kb_layout"] = "us",
    ["input.kb_variant"] = "intl",
    ["input.kb_model"] = "",
    ["input.kb_options"] = "lv3:switch",
    ["input.kb_rules"] = "",
    ["input.follow_mouse"] = 1,
    ["input.sensitivity"] = 0,
    ["input.touchpad.natural_scroll"] = false,
})

hl.config({
    ["xwayland.force_zero_scaling"] = true,
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

require("animations")
require("rules")
require("keybinds.keybinds")

-- Run once at compositor startup, rather than again on every config reload.
hl.on("hyprland.start", function()
    hl.exec_cmd("pgrep -x waybar >/dev/null || waybar")
    hl.exec_cmd("pgrep -x swaync >/dev/null || swaync")
    hl.exec_cmd([[bash "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/wallpaper.sh" --restore]])
    hl.exec_cmd("fcitx5")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("QT_QPA_PLATFORMTHEME=qt6ct /usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd([[if [ -x "$HOME/Scripts/battery-checknow" ]; then "$HOME/Scripts/battery-checknow"; fi]])
end)
