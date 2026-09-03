-- Window rules: the Garuda set for apps used on this machine, merged with
-- the Omarchy-specific bits (Nautilus glass). Skipped from Garuda: rules for
-- apps not installed here (swappy, swayimg, pavucontrol, OBS, Blanket,
-- Lxappearance, wdisplays, nwg-look, thunar, virt-manager, btrfs-assistant,
-- WebCord, telegram, Chromium, cava, kitty-radio/idling, termfloat,
-- wlfreerdp, polkit-kde) — they stay in the Garuda dotfiles repo. The
-- special:floating move{} coords were dropped (tuned for the old monitor;
-- center = true covers it) and oversized windows clamped to the 1200x750
-- logical panel. No kitty opaque rule: kitty runs background_opacity 0.9
-- (kitty.conf) with blur behind it.

-- Dialogs (by title)
hl.window_rule({ match = { title = "^Open File" },        float = true, center = true })
hl.window_rule({ match = { title = "^Select a File" },    float = true, center = true })
hl.window_rule({ match = { title = "^Choose wallpaper" }, float = true, center = true })
hl.window_rule({ match = { title = "^Open Folder" },      float = true, center = true })
hl.window_rule({ match = { title = "^Save As" },          float = true, center = true })
hl.window_rule({ match = { title = "^Library" },          float = true, center = true })
hl.window_rule({ match = { title = "^Opening" },          float = true, center = true })

-- Apps on workspaces (zen=2, ferdium=3, freetube=4, music=5)
hl.window_rule({ match = { class = "zen" },               workspace = "2" })
hl.window_rule({ match = { class = "(?i)^ferdium$" },     workspace = "3" })  -- real class is "Ferdium"; (?i) = case-insensitive
hl.window_rule({ match = { class = "freetube" },          opaque = true, workspace = "4" })
hl.window_rule({ match = { class = "kitty-cliamp" },      workspace = "5" })
hl.window_rule({ match = { class = "kitty-sync" },        fullscreen = true })

-- "N" workspace: the gnome app tiles on special:floating
hl.window_rule({ match = { class = "^org.gnome.Nautilus$" },   float = true, center = true, size = { 994, 635 }, opacity = 0.8, xray = true, workspace = "special:floating" })
hl.window_rule({ match = { class = "^org.gnome.Calculator" }, float = true, center = true, opaque = true, size = { 360, 616 }, workspace = "special:floating" })
hl.window_rule({ match = { class = "^org.gnome.Weather" },    float = true, center = true, opaque = true, size = { 1100, 503 }, workspace = "special:floating" })
hl.window_rule({ match = { class = "^org.gnome.clocks" },     float = true, center = true, size = { 615, 563 }, workspace = "special:floating" })

-- Media / popups
hl.window_rule({ match = { class = "mpv" },   float = true, center = true, opaque = true, size = { 1100, 620 } })
hl.window_rule({ match = { title = "^Webcam$" }, float = true, center = true, opaque = true, size = { 1100, 620 } })  -- webcam2.sh ffplay popup
hl.window_rule({ match = { class = "zenity" },      float = true, center = true })
hl.window_rule({ match = { class = "xdg-desktop-portal-gtk" }, float = true, center = true })
hl.window_rule({ match = { class = "xdg-desktop-portal-kde" }, float = true, center = true })

-- Image viewers (Omarchy's set)
hl.window_rule({ match = { class = "^org.gnome.eog" },  float = true, center = true })
hl.window_rule({ match = { class = "^org.gnome.Snapshot" },  float = true, center = true })
-- Picture-in-Picture (Zen)
hl.window_rule({ match = { title = "Picture-in-Picture" }, opacity = "0.95 0.75", pin = true, float = true, center = true, size = { "monitor_w * 0.25", "monitor_h * 0.25" } })

-- Single-window chrome (border off, gaps off, rounding ALWAYS on) is applied
-- dynamically per bar state by hypr/scripts/bar-toggle — the border-less
-- look only exists while the bar is hidden.
