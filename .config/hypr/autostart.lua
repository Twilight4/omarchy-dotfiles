-- Extra autostart processes.
-- o.launch_on_start("my-service")
-- Cursor theme (Bibata, same as the official dotfiles; gtk-3.0/4.0
-- settings.ini carry the GTK side, setup-cursor.sh applies it live)
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")
o.launch_on_start("hyprctl setcursor Bibata-Modern-Classic 24")

-- On-screen keyboard (wvkbd) is toggled manually via a hyprgrass touchscreen
-- gesture (swipe up from bottom edge) - see bindings.lua and
-- ~/.config/hypr/scripts/osk-toggle.sh. Nothing to autostart: the gesture
-- launches wvkbd on demand.

-- Auto-rotate the built-in panel from the accelerometer (iio-sensor-proxy).
-- Exits silently when the sensor/panel is absent; `auto-rotate.sh lock`
-- freezes the transform (e.g. reading lying down).
o.launch_on_start(os.getenv("HOME") .. "/.config/hypr/scripts/auto-rotate.sh")
-- Load hyprpm plugins (hyprgrass touch gestures), then re-parse the config
-- ONCE so the guarded hyprgrass binds in bindings.lua register: hyprpm loads
-- plugins after the initial config parse, so without this the gestures are
-- dead on every fresh session. The runtime lockfile breaks the loop this
-- would otherwise cause (hyprctl reload re-runs this autostart block).
o.launch_on_start(
  'sh -c \'L="${XDG_RUNTIME_DIR:-/tmp}/hyprpm-reloaded"; [ -f "$L" ] || { hyprpm reload -n; touch "$L"; sleep 1; hyprctl reload; }\''
)
