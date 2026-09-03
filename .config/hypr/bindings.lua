-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
-- Touchscreen gesture (hyprgrass): swipe up from the bottom edge toggles the
-- on-screen keyboard. Sensitivity 10.0: low values leave the workspace swipe stuck following the
-- finger after liftoff (screen bounces back); 10.0 ends the swipe cleanly.
-- Guarded like the official gestures.lua: hyprpm loads plugins AFTER the
-- config parses, so an unguarded plugin.* config errors at startup/reload
-- ("unknown option plugin:hyprgrass:sensitivity") whenever the plugin isn't
-- loaded yet.
if hl.plugin.hyprgrass ~= nil then
    hl.config({
      plugin = {
        hyprgrass = {
          sensitivity = 10.0,
          -- px from screen edge that still counts as an edge swipe
          edge_margin = 40,
        },
      },
    })
    hl.plugin.hyprgrass.bind({
      pattern = { kind = "edge", origin = "down", direction = "up" },
      action = hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/osk-toggle.sh"),
    })
    -- 2-finger tap toggles float
    hl.plugin.hyprgrass.bind({
      pattern = { kind = "tap", fingers = 2 },
      action = hl.dsp.window.float(),
    })
    -- 3-finger long-press, then move = drag the window (hyprgrass has no
    -- double-tap-hold gesture; 1-finger long-press was dropped because apps
    -- like browsers use it for the context menu). mouse=true drives the
    -- mouse dispatcher.
    hl.plugin.hyprgrass.bind({
      pattern = { kind = "longpress", fingers = 3 },
      action = hl.dsp.window.drag(),
      mouse = true,
    })
    -- 2-finger long-press, then move = resize the window
    hl.plugin.hyprgrass.bind({
      pattern = { kind = "longpress", fingers = 2 },
      action = hl.dsp.window.resize(),
      mouse = true,
    })
    -- Pinch is deliberately NOT bound: with no hyprgrass pinch bind, the
    -- gesture passes through to apps, which handle zoom natively
    -- (browser/web-app default behaviour the user prefers).
    -- 1-finger swipes in from the left/right screen edge switch workspaces
    -- (animated, follows the finger). Bottom edge stays the OSK toggle.
    hl.plugin.hyprgrass.gesture({
      pattern = { kind = "edge", origin = "left", direction = "right" },
      action = "workspace",
    })
    hl.plugin.hyprgrass.gesture({
      pattern = { kind = "edge", origin = "right", direction = "left" },
      action = "workspace",
    })
    -- 2-finger horizontal swipe anywhere switches workspaces (follows the
    -- finger). Replaces Hyprland's native workspace_swipe_touch, whose core
    -- state machine wedges — disabled in input.lua.
    hl.plugin.hyprgrass.gesture({
      pattern = { kind = "swipe", fingers = 2, direction = "horizontal" },
      action = "workspace",
    })
    -- Touchscreen: 2-finger swipe up toggles the hyprexpo overview (mirrors
    -- the touchpad gesture; discrete bind so it fires once on completion,
    -- not per animation frame). Nil-guarded: hyprexpo may be absent.
    hl.plugin.hyprgrass.bind({
      pattern = { kind = "swipe", fingers = 2, direction = "up" },
      action = function()
        if hl.plugin.hyprexpo then hl.plugin.hyprexpo.expo("toggle") end
      end,
    })
    -- 2-finger swipe down closes the active window (mirrors SUPER+Q).
    hl.plugin.hyprgrass.bind({
      pattern = { kind = "swipe", fingers = 2, direction = "down" },
      action = hl.dsp.window.close(),
    })
    -- 3-finger tap toggles fullscreen on the active window.
    hl.plugin.hyprgrass.bind({
      pattern = { kind = "tap", fingers = 3 },
      action = hl.dsp.window.fullscreen(),
    })
    -- 3-finger swipe down toggles the top bar (same command as
    -- SUPER+SHIFT+SPACE). Touchpad mirror is below, outside this block.
    hl.plugin.hyprgrass.bind({
      pattern = { kind = "swipe", fingers = 3, direction = "down" },
      action = hl.dsp.exec_cmd("omarchy-toggle-bar"),
    })
    -- 3-finger swipe up toggles the nwg app dock (scripts/dock-toggle.sh).
    hl.plugin.hyprgrass.bind({
      pattern = { kind = "swipe", fingers = 3, direction = "up" },
      action = hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/dock-toggle.sh"),
    })
    -- 4-finger swipe up toggles the big-icons app launcher (touch-native,
    -- rofi has no wl_touch): 2 fingers = expo, 3 = dock, 4 = launcher.
    hl.plugin.hyprgrass.bind({
      pattern = { kind = "swipe", fingers = 4, direction = "up" },
      action = hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/app-launcher.sh"),
    })
end
-- hyprexpo (expose-style workspace overview, sandwichfarm fork). Same
-- load-order guard as hyprgrass: hyprpm loads plugins after the config
-- parses (autostart.lua re-parses once the plugins are in).
if hl.plugin.hyprexpo ~= nil then
    -- Background follows the Omarchy theme (parsed from the theme state;
    -- omarchy theme set reloads the config, so this re-reads on change).
    local expo_bg = "rgb(101315)"
    local theme_file = io.open(os.getenv("HOME") .. "/.local/state/omarchy/current/theme/kitty.conf", "r")
    if theme_file then
        for line in theme_file:lines() do
            local hex = line:match("^background%s+#(%x+)")
            if hex then expo_bg = "rgb(" .. hex .. ")" end
        end
        theme_file:close()
    end
    hl.config({ plugin = { hyprexpo = {
        columns = 3,
        bg_col = expo_bg,
        workspace_method = "center current",
        skip_empty = 0,
        gesture_distance = 200,
        cancel_key = "escape",
    }}})
    -- 4-finger swipe UP on the touchpad opens the overview (native gesture).
    -- 2-finger swipes are eaten by touchpad scrolling (verified), so the
    -- touchpad mirror lives on 4. Touchscreen stays 2. 3-finger horizontal
    -- stays workspace switching, 3-finger up is the app dock.
    hl.plugin.hyprexpo.gesture({ fingers = 4, direction = "up", action = "expo" })
    hl.bind("SUPER + grave", function() hl.plugin.hyprexpo.expo("toggle") end)
end

-- Touchpad 3-finger set (native gestures, no plugin): horizontal =
-- workspaces, down = top bar, up = app dock. Hyprexpo lives on 2 fingers,
-- matching the touchscreen.
hl.gesture({ fingers = 3, direction = "down", action = function()
  hl.dispatch(hl.dsp.exec_cmd("omarchy-toggle-bar"))
end })

-- Touchpad: 3-finger swipe up toggles the nwg app dock (dock-toggle.sh).
hl.gesture({ fingers = 3, direction = "up", action = function()
  hl.dispatch(hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/dock-toggle.sh"))
end })

-- App launcher split by input method: SUPER+R opens the classic Omarchy
-- apps menu (keyboard flow); the big-icons quickshell grid
-- (.config/qs-applauncher) is the touch flow via the 4-finger swipe-up
-- gesture and the nwg dock launcher button.
o.bind("SUPER + R", "Apps menu", "omarchy-menu toggle apps")

-- Power/session menu: wlogout on the physical power button, replacing
-- Omarchy's default "omarchy-menu toggle system". Blur behind it comes from
-- the layer rule in looknfeel.lua.
hl.unbind("XF86PowerOff")
o.bind("XF86PowerOff", "Power menu", "pkill wlogout || wlogout", { locked = true })

-- ---------------------------------------------------------------------------
-- 2026-08-31: Garuda dotfiles migration (dotfiles/.config/hypr/configs/
-- keybinds.lua + ws-scripts/). Letter workspaces, special-workspace stack,
-- ws-scripts, Garuda menu keys. Displaced Omarchy menus (Network, Toggle
-- menu, Power, ...) stay reachable through the SUPER+SPACE root menu.
-- ---------------------------------------------------------------------------

-- === Unbind replaced/dropped Omarchy defaults ==============================

-- Browsers -> ws-zen; system menu -> power button (wlogout, above)
hl.unbind("SUPER + SHIFT + RETURN")                      -- Browser
hl.unbind("SUPER + SHIFT + B")                           -- Browser
hl.unbind("SUPER + SHIFT + ALT + B")                     -- Browser (private) -> theme menu
hl.unbind("SUPER + SHIFT + F")                           -- File manager
hl.unbind("SUPER + ALT + SHIFT + F")                     -- File manager (cwd)
hl.unbind("SUPER + ESCAPE")                              -- System menu
hl.unbind("SUPER + SHIFT + SLASH")                       -- Passwords
hl.unbind("SUPER + SHIFT + W")                           -- Omawrite
hl.unbind("SUPER + SHIFT + X")                           -- X
hl.unbind("SUPER + ALT + RETURN")                        -- Tmux
hl.unbind("SUPER + CTRL + RETURN")                       -- Herdr
hl.unbind("SUPER + ALT + K")                             -- Tmux keybindings
hl.unbind("SUPER + CTRL + K")                            -- Herdr keybindings -> addmaster
hl.unbind("SUPER + CTRL + Q")                            -- Calculator
hl.unbind("SUPER + CTRL + T")                            -- Activity
hl.unbind("SUPER + SHIFT + A")                           -- ChatGPT
hl.unbind("SUPER + SHIFT + ALT + A")                     -- Grok
hl.unbind("SUPER + SHIFT + ALT + E")                     -- New email
hl.unbind("SUPER + SHIFT + ALT + G")                     -- WhatsApp
hl.unbind("SUPER + SHIFT + ALT + M")                     -- Music TUI
hl.unbind("SUPER + SHIFT + ALT + X")                     -- X Post
hl.unbind("SUPER + SHIFT + ALT + LEFT")                  -- Move workspace to left monitor
hl.unbind("SUPER + SHIFT + ALT + RIGHT")                 -- Move workspace to right monitor
hl.unbind("SUPER + SHIFT + ALT + UP")                    -- Move workspace to up monitor
hl.unbind("SUPER + SHIFT + ALT + DOWN")                  -- Move workspace to down monitor
hl.unbind("SUPER + SHIFT + CTRL + A")                    -- Agent
hl.unbind("SUPER + SHIFT + CTRL + G")                    -- Google Messages
hl.unbind("SUPER + SHIFT + D")                           -- Docker
hl.unbind("SUPER + SHIFT + E")                           -- Email
hl.unbind("SUPER + SHIFT + G")                           -- Signal
hl.unbind("SUPER + SHIFT + M")                           -- Music
hl.unbind("SUPER + SHIFT + N")                           -- Editor
hl.unbind("SUPER + SHIFT + O")                           -- Obsidian
hl.unbind("SUPER + SHIFT + P")                           -- Google Photos
hl.unbind("SUPER + SHIFT + S")                           -- Google Maps -> center window
hl.unbind("SUPER + SHIFT + BACKSPACE")                   -- Toggle window gaps
hl.unbind("SUPER + S")                                   -- Toggle scratchpad (tiling.lua) -> SUPER+comma in this layout
hl.unbind("SUPER + ALT + S")                             -- Move window to scratchpad -> SUPER+SHIFT+comma in this layout

-- Letter workspaces replace the numeric workspace/move/silent-move binds.
for key_code = 10, 19 do
  hl.unbind("SUPER + code:" .. key_code)                 -- Switch to workspace N
  hl.unbind("SUPER + SHIFT + code:" .. key_code)         -- Move window to workspace N
  hl.unbind("SUPER + SHIFT + ALT + code:" .. key_code)   -- Move window silently to workspace N
end

-- Workspace cycling and directional focus -> Garuda focus/master binds
hl.unbind("SUPER + TAB")                                 -- Next workspace -> focus next monitor
hl.unbind("SUPER + SHIFT + TAB")                         -- Previous workspace
hl.unbind("SUPER + CTRL + TAB")                          -- Former workspace
hl.unbind("SUPER + LEFT")                                -- Focus left
hl.unbind("SUPER + RIGHT")                               -- Focus right
hl.unbind("SUPER + UP")                                  -- Focus above
hl.unbind("SUPER + DOWN")                                -- Focus below
hl.unbind("SUPER + SHIFT + LEFT")                        -- Swap window left
hl.unbind("SUPER + SHIFT + RIGHT")                       -- Swap window right
hl.unbind("SUPER + SHIFT + UP")                          -- Swap window up
hl.unbind("SUPER + SHIFT + DOWN")                        -- Swap window down
hl.unbind("CTRL + ALT + TAB")                            -- Focus next monitor
hl.unbind("CTRL + ALT + SHIFT + TAB")                    -- Focus previous monitor

-- Tiling keys reassigned
hl.unbind("SUPER + W")                                   -- Close window -> SUPER+Q
hl.unbind("SUPER + J")                                   -- Toggle split -> cyclenext
hl.unbind("SUPER + O")                                   -- Pop window out -> workspace 3
hl.unbind("SUPER + P")                                   -- Pseudo -> workspace 5
hl.unbind("SUPER + L")                                   -- Workspace layout (layout pinned to master, looknfeel.lua)
hl.unbind("SUPER + CTRL + Delete")                       -- Toggle laptop display -> uwsm stop

-- Window groups: unused
hl.unbind("SUPER + G")                                   -- Toggle grouping
hl.unbind("SUPER + ALT + G")                             -- Out of group -> glassmorphism
hl.unbind("SUPER + ALT + LEFT")                          -- Into group left
hl.unbind("SUPER + ALT + RIGHT")                         -- Into group right
hl.unbind("SUPER + ALT + UP")                            -- Into group top
hl.unbind("SUPER + ALT + DOWN")                          -- Into group bottom
hl.unbind("SUPER + ALT + TAB")                           -- Group next -> move workspace to monitor
hl.unbind("SUPER + ALT + SHIFT + TAB")                   -- Group previous
hl.unbind("SUPER + CTRL + LEFT")                         -- Grouped focus left
hl.unbind("SUPER + CTRL + RIGHT")                        -- Grouped focus right
hl.unbind("SUPER + ALT + mouse_down")                    -- Group scroll next
hl.unbind("SUPER + ALT + mouse_up")                      -- Group scroll previous
for key_code = 10, 14 do
  hl.unbind("SUPER + ALT + code:" .. key_code)           -- Switch to group window N
end

-- Universal clipboard keys re-homed
hl.unbind("SUPER + C")                                   -- Universal copy -> clipboard manager
hl.unbind("SUPER + V")                                   -- Universal paste (left free)
hl.unbind("SUPER + X")                                   -- Universal cut -> Keybindings menu
hl.unbind("SUPER + SHIFT + C")                           -- Calendar (removed at user request)
hl.unbind("SUPER + CTRL + V")                            -- Clipboard manager -> SUPER+C (taeryn.clipboard)

-- Notifications reshuffled to Garuda keys
hl.unbind("SUPER + comma")                               -- Dismiss last -> SUPER+V
hl.unbind("SUPER + SHIFT + comma")                       -- Dismiss all -> SUPER+CTRL+SPACE
hl.unbind("SUPER + CTRL + comma")                        -- Silencing -> SUPER+CTRL+D
hl.unbind("SUPER + SHIFT + ALT + comma")                 -- Open notification history -> merged into the SUPER+CTRL+SPACE toggle

-- Moved Omarchy toggles/menus
hl.unbind("SUPER + CTRL + L")                            -- Lock -> SUPER+Y
hl.unbind("SUPER + CTRL + I")                            -- Idle lock -> SUPER+CTRL+Y (ws-emacs takes key)
hl.unbind("SUPER + CTRL + N")                            -- Nightlight -> SUPER+backslash
hl.unbind("SUPER + CTRL + D")                            -- Display -> SUPER+CTRL+ALT+D
hl.unbind("SUPER + CTRL + ALT + D")                      -- Calendar -> SUPER+CTRL+ALT+C
hl.unbind("SUPER + SHIFT + CTRL + SPACE")                -- Theme menu -> SUPER+SHIFT+ALT+B
hl.unbind("SUPER + CTRL + SPACE")                        -- Background switcher -> SUPER+ALT+B
hl.unbind("SUPER + K")                                   -- Keybindings -> SUPER+X
hl.unbind("SUPER + CTRL + X")                            -- Dictation -> F1; key -> color picker
hl.unbind("F9")                                          -- Dictation push-to-talk start/stop

-- ws-scripts keys: these Omarchy menus move to new keys (bound below)
hl.unbind("SUPER + CTRL + W")                            -- Network -> SUPER+CTRL+ALT+N
hl.unbind("SUPER + CTRL + O")                            -- Toggle menu -> SUPER+CTRL+T
hl.unbind("SUPER + CTRL + P")                            -- Power -> SUPER+CTRL+ALT+P

-- === Garuda bindings =======================================================

-- WM focus / master layout (ALT+TAB keeps the Omarchy combined focus+reveal)
o.bind("SUPER + TAB", "Focus next monitor", hl.dsp.focus({ monitor = "+1" }))
o.bind("SUPER + ALT + TAB", "Move workspace to next monitor", hl.dsp.workspace.move({ monitor = "+1" }))
o.bind("SUPER + J", "Focus next window", hl.dsp.layout("cyclenext"))
o.bind("SUPER + K", "Focus previous window", hl.dsp.layout("cycleprev"))
o.bind("SUPER + CTRL + K", "Add master window", hl.dsp.layout("addmaster"))
o.bind("SUPER + CTRL + J", "Remove master window", hl.dsp.layout("removemaster"))
o.bind("SUPER + SHIFT + J", "Swap with next window", hl.dsp.layout("swapnext"))
o.bind("SUPER + SHIFT + K", "Swap with previous window", hl.dsp.layout("swapprev"))

-- Resize
o.bind("SUPER + ALT + H", "Resize window left", hl.dsp.window.resize({ x = -60, y = 0, relative = true }), { repeating = true })
o.bind("SUPER + ALT + J", "Resize window down", hl.dsp.window.resize({ x = 0, y = 60, relative = true }), { repeating = true })
o.bind("SUPER + ALT + K", "Resize window up", hl.dsp.window.resize({ x = 0, y = -60, relative = true }), { repeating = true })
o.bind("SUPER + ALT + L", "Resize window right", hl.dsp.window.resize({ x = 60, y = 0, relative = true }), { repeating = true })

-- Workspaces 1-6 on letters (I W O U P E)
o.bind("SUPER + I", "Workspace 1 (main)", hl.dsp.focus({ workspace = "1" }))
o.bind("SUPER + W", "Workspace 2 (browser)", hl.dsp.focus({ workspace = "2" }))
o.bind("SUPER + O", "Workspace 3 (ferdium)", hl.dsp.focus({ workspace = "3" }))
o.bind("SUPER + U", "Workspace 4 (freetube)", hl.dsp.focus({ workspace = "4" }))
o.bind("SUPER + P", "Workspace 5 (music)", hl.dsp.focus({ workspace = "5" }))
o.bind("SUPER + E", "Workspace 6 (extra)", hl.dsp.focus({ workspace = "6" }))

-- Apps on workspaces (open-or-focus ws-scripts)
o.bind("SUPER + CTRL + I", "Emacs workspace", "~/.config/hypr/ws-scripts/ws-emacs")
o.bind("SUPER + CTRL + W", "Zen browser workspace", "~/.config/hypr/ws-scripts/ws-zen")
o.bind("SUPER + CTRL + U", "FreeTube workspace", "~/.config/hypr/ws-scripts/ws-freetube")
o.bind("SUPER + CTRL + O", "Ferdium workspace", "~/.config/hypr/ws-scripts/ws-ferdium")
o.bind("SUPER + CTRL + P", "Music workspace", "~/.config/hypr/ws-scripts/ws-cliamp")
o.bind("SUPER + CTRL + N", "Clocks / weather / calculator", 'bash -c "uwsm app -- gnome-clocks & uwsm app -- gnome-weather & uwsm app -- gnome-calculator &"')

-- Move window to workspace (SHIFT) / silently (ALT)
o.bind("SUPER + SHIFT + I", "Move window to workspace 1", hl.dsp.window.move({ workspace = "1" }))
o.bind("SUPER + SHIFT + W", "Move window to workspace 2", hl.dsp.window.move({ workspace = "2" }))
o.bind("SUPER + SHIFT + O", "Move window to workspace 3", hl.dsp.window.move({ workspace = "3" }))
o.bind("SUPER + SHIFT + U", "Move window to workspace 4", hl.dsp.window.move({ workspace = "4" }))
o.bind("SUPER + SHIFT + P", "Move window to workspace 5", hl.dsp.window.move({ workspace = "5" }))
o.bind("SUPER + SHIFT + E", "Move window to workspace 6", hl.dsp.window.move({ workspace = "6" }))
o.bind("SUPER + ALT + I", "Move window to workspace 1 (silent)", hl.dsp.window.move({ workspace = "1", follow = false }))
o.bind("SUPER + ALT + W", "Move window to workspace 2 (silent)", hl.dsp.window.move({ workspace = "2", follow = false }))
o.bind("SUPER + ALT + O", "Move window to workspace 3 (silent)", hl.dsp.window.move({ workspace = "3", follow = false }))
o.bind("SUPER + ALT + U", "Move window to workspace 4 (silent)", hl.dsp.window.move({ workspace = "4", follow = false }))
o.bind("SUPER + ALT + P", "Move window to workspace 5 (silent)", hl.dsp.window.move({ workspace = "5", follow = false }))

-- Free workspaces 7-9 on digits 1/2/3 (non-standard apps: maps, drive...)
o.bind("SUPER + code:10", "Workspace 7 (free)", hl.dsp.focus({ workspace = "7" }))
o.bind("SUPER + code:11", "Workspace 8 (free)", hl.dsp.focus({ workspace = "8" }))
o.bind("SUPER + code:12", "Workspace 9 (free)", hl.dsp.focus({ workspace = "9" }))
o.bind("SUPER + SHIFT + code:10", "Move window to workspace 7", hl.dsp.window.move({ workspace = "7" }))
o.bind("SUPER + SHIFT + code:11", "Move window to workspace 8", hl.dsp.window.move({ workspace = "8" }))
o.bind("SUPER + SHIFT + code:12", "Move window to workspace 9", hl.dsp.window.move({ workspace = "9" }))
o.bind("SUPER + ALT + code:10", "Move window to workspace 7 (silent)", hl.dsp.window.move({ workspace = "7", follow = false }))
o.bind("SUPER + ALT + code:11", "Move window to workspace 8 (silent)", hl.dsp.window.move({ workspace = "8", follow = false }))
o.bind("SUPER + ALT + code:12", "Move window to workspace 9 (silent)", hl.dsp.window.move({ workspace = "9", follow = false }))

-- Special workspaces
-- (special:other dropped: SUPER+L returns to Omarchy's workspace-layout toggle)
o.bind("SUPER + comma", "Toggle special:scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
o.bind("SUPER + M", "Toggle special:comma", hl.dsp.workspace.toggle_special("comma"))
o.bind("SUPER + N", "Toggle special:floating", hl.dsp.workspace.toggle_special("floating"))

-- SUPER+H: toggle special:magic and pull the active window into it
o.bind("SUPER + H", "Toggle special:magic with window", function()
    hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
    hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
    hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
    hl.dispatch(hl.dsp.window.move({ workspace = "special:magic" }))
    hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
end)


o.bind("SUPER + SHIFT + comma", "Move window to special:scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
o.bind("SUPER + SHIFT + M", "Move window to special:comma", hl.dsp.window.move({ workspace = "special:comma", follow = false }))
o.bind("SUPER + SHIFT + N", "Move window to special:floating", hl.dsp.window.move({ workspace = "special:floating", follow = false }))

-- WM ops / session
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())
o.bind("SUPER + SHIFT + S", "Center window", hl.dsp.window.center())
o.bind("SUPER + D", "Toggle app dock", "~/.config/hypr/scripts/dock-toggle.sh")
o.bind("CTRL + ALT + End", "Sync dashboard (kitty)", "uwsm app -- kitty -1 --class kitty-sync -T kitty-sync --session ~/.config/kitty/session-sync")
o.bind("SUPER + CTRL + End", "Power off", "systemctl poweroff")
o.bind("SUPER + CTRL + Delete", "End session (uwsm stop)", "uwsm stop")

-- Tools
o.bind("SUPER + ALT + T", "Gamemode", "~/.config/hypr/scripts/gamemode")
-- Touchscreen recovery: hyprgrass edge-swipe can wedge the gesture state
-- when a finger rests on the screen edge mid-swipe (upstream issue #147) —
-- reload the plugin to reset it.
o.bind("SUPER + SHIFT + ALT + T", "Reset touch gestures", "~/.config/hypr/scripts/touch-reset.sh")
o.bind("SUPER + ALT + G", "Glassmorphism", "~/.config/hypr/scripts/glassmorphism-toggle")

-- Omarchy features re-homed to Garuda keys
o.bind("SUPER + X", "Keybindings", "omarchy-menu-keybindings")
o.bind("SUPER + C", "Clipboard manager", "omarchy-shell shell toggle taeryn.clipboard")
o.bind("SUPER + Y", "Lock system", "omarchy-system-lock")
o.bind("SUPER + SHIFT + ALT + B", "Theme menu", "omarchy-menu toggle theme")
o.bind("SUPER + ALT + B", "Background switcher", "omarchy-menu toggle background")
o.bind("SUPER + CTRL + SPACE", "Toggle notification history", "omarchy-shell notifications toggleHistory")
o.bind("SUPER + period", "Dismiss last notification", "omarchy-shell notifications dismissOne")
o.bind("SUPER + CTRL + X", "Color picker", "pkill hyprpicker || hyprpicker -a")
o.bind("SUPER + CTRL + ALT + D", "Display", "omarchy-shell shell toggle omarchy.monitor")
o.bind("SUPER + CTRL + ALT + N", "Network", "omarchy-shell shell toggle omarchy.network")
o.bind("SUPER + CTRL + ALT + P", "Power", "omarchy-shell shell toggle omarchy.power")

-- Top bar. Single-window chrome (gaps/border) follows the bar state via
-- scripts/bar-watch, which watches the bar-off flag — covers every toggle
-- path (keybind, menu, 3-finger swipe)
hl.unbind("SUPER + SHIFT + SPACE")
o.bind("SUPER + SHIFT + SPACE", "Toggle top bar", "omarchy-toggle-bar")
o.bind("SUPER + CTRL + T", "Toggle menu", "omarchy-menu toggle toggle")



-- Night light: toggle + 10% temperature steps, all with notifications
o.bind("SUPER + backslash", "Toggle nightlight", "~/.config/hypr/scripts/nightlight.sh toggle")
o.bind("SUPER + ALT + backslash", "Night light warmer (-10%)", "~/.config/hypr/scripts/nightlight.sh warmer")
o.bind("SUPER + SHIFT + backslash", "Night light cooler (+10%)", "~/.config/hypr/scripts/nightlight.sh cooler")
o.bind_toggle("SUPER + CTRL + Y", "Toggle locking on idle", "idle")
o.bind_toggle("SUPER + CTRL + D", "Toggle silencing notifications", "notification-silencing")

if o.cmd_present("voxtype") then
  o.bind("F1", "Toggle dictation", "voxtype record toggle")
end
