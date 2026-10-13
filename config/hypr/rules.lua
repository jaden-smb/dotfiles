-- https://wiki.hypr.land/configuring/core/rules/
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({
    name = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true },
    no_focus = true,
})

hl.window_rule({ match = { title = "^(KDE Connect URL handler)$" }, float = true })
hl.window_rule({ match = { title = "^(Pipewire Volume Control)$" }, float = true })
hl.window_rule({
    name = "float-thunar-rename",
    match = { class = "thunar", title = "(Rename )(.*)" },
    float = true,
})

hl.window_rule({ match = { class = "thunar" }, opacity = "0.8" })
hl.window_rule({ match = { class = "rofi" }, opacity = "0.8" })
hl.window_rule({ match = { class = "^(hyprpolkitagent)$" }, opacity = "0.85" })
hl.window_rule({ match = { class = "claudeai-nativefier-859bac" }, opacity = "0.88" })
hl.window_rule({ match = { class = "(.*)(YouTube Music Desktop App)(.*)" }, opacity = "0.75" })
hl.window_rule({ match = { class = "(.*)(discord)(.*)" }, opacity = "0.77" })
hl.window_rule({
    name = "discord-fullscreen-opacity",
    match = { class = "(.*)(discord)(.*)", fullscreen = true },
    opacity = "1",
})

hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true, ignore_alpha = 0.1 })
hl.layer_rule({ match = { namespace = "gtk-layer-shell" }, blur = true, ignore_alpha = 0.1 })
hl.layer_rule({ match = { namespace = "awww" }, blur = true })
hl.layer_rule({ match = { namespace = "rofi" }, blur = true, blur_popups = true, ignore_alpha = 0.5 })
