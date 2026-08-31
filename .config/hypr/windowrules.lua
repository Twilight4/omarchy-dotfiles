hl.window_rule({ match = { class = "^org.gnome.eog" },  float = true, center = true })
hl.window_rule({ match = { class = "^org.gnome.Snapshot" },  float = true, center = true })

-- Nautilus: translucent window with blur behind it (file browser glass).
hl.window_rule({ match = { class = "^org.gnome.Nautilus$" }, opacity = 0.8, xray = true })
