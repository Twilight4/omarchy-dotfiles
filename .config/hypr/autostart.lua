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
