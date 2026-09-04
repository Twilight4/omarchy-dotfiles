-- Extra autostart processes.
-- Stock Omarchy already imports the session environment (systemctl --user
-- import-environment + dbus-update-activation-environment --systemd --all),
-- launches the shell/bar, udiskie, portals and the polkit agent — the Garuda
-- gtkthemes / launch-variables / launch-portals lines are not needed here.
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

-- Single-window chrome follows the bar state: bar-watch polls the bar-off
-- flag (every toggle path flips it) and syncs runtime gaps/border rules.
o.launch_on_start(os.getenv("HOME") .. "/.config/hypr/scripts/bar-watch")

-- Lid close only suspends when the screen is unlocked: the daemon holds a
-- logind handle-lid-switch block inhibitor while the session lock is
-- engaged (SUPER+Y), so a locked screen keeps running with the lid closed.
o.launch_on_start(os.getenv("HOME") .. "/.config/hypr/scripts/lid-inhibit-when-locked")

-- Load hyprpm plugins (hyprgrass touch gestures), then re-parse the config
-- ONCE so the guarded hyprgrass binds in bindings.lua register: hyprpm loads
-- plugins after the initial config parse, so without this the gestures are
-- dead on every fresh session. The runtime lockfile breaks the loop this
-- would otherwise cause (hyprctl reload re-runs this autostart block).
o.launch_on_start(
  'sh -c \'L="${XDG_RUNTIME_DIR:-/tmp}/hyprpm-reloaded"; [ -f "$L" ] || { hyprpm reload -n; touch "$L"; sleep 1; hyprctl reload; }\''
)

-- Session apps (imported from the Garuda autostart; omarchy-native services
-- like swaync/polkit/wallpaper/bar have their omarchy equivalents already).
hl.on("hyprland.start", function()
    -- Key remapper (Emacs-style binds, scoped to Zen)
    hl.exec_cmd('uwsm app -d "Xremap key remapper" -- xremap ~/.config/xremap/config.yml --watch=config,device')
    hl.exec_cmd('uwsm app -d "Emacs server" -- emacs --daemon')
    hl.exec_cmd("uwsm app -- udev-block-notify")

    -- Workspaces: emacs (1), zen (2), ferdium (3), freetube (4), music (5)
    hl.exec_cmd("~/.config/hypr/ws-scripts/ws-emacs")
    hl.exec_cmd("~/.config/hypr/ws-scripts/ws-zen")
    hl.exec_cmd("uwsm app -- freetube --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto --enable-features=VaapiVideoDecodeLinuxGL --gpu-context=wayland")
    -- Music workspace (ws5): cliamp TUI with Mixed playlist playing at -20 dB
    hl.exec_cmd("uwsm app -- kitty --class kitty-cliamp -e cliamp --vol -20 --playlist Mixed --auto-play")
    hl.exec_cmd("uwsm app -- ferdium --socket=wayland --ozone-platform-hint=auto --ozone-platform=wayland --enable-features-WaylandWindowDecorations")

    -- App dock along the bottom edge: dock-toggle.sh launches it in
    -- auto-hide mode and nudges it visible (same path as SUPER+D)
    hl.exec_cmd('uwsm app -d "App dock" -- ~/.config/hypr/scripts/dock-toggle.sh')

    -- Land on an empty workspace (7 = first free, SUPER+1)
    hl.exec_cmd([[sleep 5 && hyprctl dispatch 'hl.dsp.focus({workspace="7"})']])
end)
