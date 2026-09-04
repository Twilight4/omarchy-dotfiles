-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Keyboard layout and options.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
-- hl.config({
--   input = {
--     -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt.
--     kb_layout = "us,dk,eu",
--     kb_options = "compose:caps,shift:both_capslock_cancel,grp:alts_toggle",
--
--     -- Use a specific keyboard variant if needed (e.g. intl for international keyboards).
--     kb_variant = "intl",
--
--     -- Change speed of keyboard repeat.
--     repeat_rate = 40,
--     repeat_delay = 250,
--
--     -- Start with numlock on by default.
--     numlock_by_default = true,
--
--     -- Increase sensitivity for mouse/trackpad (default: 0).
--     sensitivity = 0.35,
--
--     -- Turn off mouse acceleration (default: adaptive).
--     accel_profile = "flat",
--
--     touchpad = {
--       -- Use natural (inverse) scrolling.
--       natural_scroll = true,
--
--       -- Use two-finger clicks for right-click instead of lower-right corner.
--       clickfinger_behavior = true,
--
--       -- Control the speed of your scrolling.
--       scroll_factor = 0.4,
--
--       -- Enable the touchpad while typing.
--       disable_while_typing = false,
--
--       -- Left-click-and-drag with three fingers.
--       drag_3fg = 1,
--     },
--   },
-- })

hl.config({
  input = {
    -- Caps Lock acts as Left Ctrl (Garuda parity; replaces Omarchy default
    -- "compose:caps,shift:both_capslock_cancel").
    kb_options = "ctrl:nocaps",
    kb_layout = "pl",
    repeat_rate = 50,
    repeat_delay = 300,

    -- No mouse acceleration (Garuda parity; Omarchy default is adaptive).
    accel_profile = "flat",

    -- Touchpad (ported from the official dotfiles general.lua — 2-in-1 panel)
    touchpad = {
      disable_while_typing    = true,
      natural_scroll          = true,
      scroll_factor           = 0.5,
      clickfinger_behavior    = true,
      middle_button_emulation = false,
      tap_to_click            = true,
    },
  },
})

-- Touchscreen workspace swipes (hyprgrass docs recommendation):
-- horizontal touch swipe switches workspaces; a small cancel ratio avoids
-- accidental switches on short swipes.
hl.config({
  gestures = {
    workspace_swipe_touch        = true, -- native core touch swipe state machine wedges (touches get stuck shifting workspaces); hyprgrass 2-finger swipe in bindings.lua replaces it
    workspace_swipe_cancel_ratio = 0.10, -- short/accidental swipes snap back instead of switching
    -- more finger travel per workspace -> the follow-the-finger motion is calmer
    workspace_swipe_distance     = 300,
  },
})
-- Touchpad: 3-finger horizontal swipe switches workspaces (native hyprland
-- gesture, no plugin needed — mirrors the touchscreen behaviour).
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- App-specific touchpad scroll speeds.
-- o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
-- o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Enable touchpad gestures for changing workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Enable touchpad gestures for moving focus (helpful on scrolling layout).
-- hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "l" })) end })
-- hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "r" })) end })
