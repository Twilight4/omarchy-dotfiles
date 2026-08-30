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
    -- 1-finger long-press, then move = drag the window (README example used
    -- longpress:1 movewindow; mouse=true drives the mouse dispatcher).
    -- 1-finger longpress isn't supported by this build.
    hl.plugin.hyprgrass.bind({
      pattern = { kind = "longpress", fingers = 1 },
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
end
-- hyprexpo (expose-style workspace overview, sandwichfarm fork). Same
-- load-order guard as hyprgrass: hyprpm loads plugins after the config
-- parses (autostart.lua re-parses once the plugins are in).
if hl.plugin.hyprexpo ~= nil then
    hl.config({ plugin = { hyprexpo = {
        columns = 3,
        bg_col = "rgb(111111)",
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

-- Rofi app launcher (config imported from the Garuda dotfiles; same
-- SUPER+R keybind). pkill toggles an open instance closed.
o.bind("SUPER + R", "Rofi app launcher", "pkill rofi || rofi -show drun -config ~/.config/rofi/configs/config.rasi")

-- Power/session menu: wlogout on the physical power button, replacing
-- Omarchy's default "omarchy-menu toggle system". Blur behind it comes from
-- the layer rule in looknfeel.lua.
hl.unbind("XF86PowerOff")
o.bind("XF86PowerOff", "Power menu", "pkill wlogout || wlogout", { locked = true })
