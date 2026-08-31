-- Extra environment variables. Loaded after the Omarchy defaults
-- (default/hypr/envs.lua) — this file only carries the Garuda envs Omarchy
-- does NOT already set (omarchy covers: GDK/QT platform, QT_QPA_PLATFORMTHEME
-- =gtk3, MOZ_ENABLE_WAYLAND, ELECTRON_OZONE_PLATFORM_HINT/OZONE_PLATFORM,
-- XDG_*, XCURSOR_SIZE, XCOMPOSEFILE, xwayland.force_zero_scaling).

hl.env("SDL_VIDEODRIVER", "wayland")                   -- SDL games/apps native Wayland
hl.env("CLUTTER_BACKEND", "wayland")                   -- legacy clutter apps
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")     -- no Qt client-side decorations
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")             -- Java GUIs render correctly
hl.env("MOZ_DISABLE_RDD_SANDBOX", "1")                 -- Firefox/Zen video decode stability
hl.env("MOZ_DBUS_REMOTE", "1")                         -- open links in the running instance

-- fcitx5 input-method wiring (the omarchy-fcitx5 user service is enabled;
-- Garuda pointed these at ibus — fcitx is the correct value here)
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
