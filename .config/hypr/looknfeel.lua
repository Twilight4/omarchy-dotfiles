-- Change the default Omarchy look'n'feel.


-- Master layout only (Garuda parity): pin the layout engine + its params.
-- The workspace-layout toggle keybind is unbound in bindings.lua.
hl.config({
  general = { layout = "master", gaps_in = 3, gaps_out = 3 },
  master = {
    orientation = "right",
    new_on_top = true,
    special_scale_factor = 0.9,
  },
})

-- Wake the screen on any input (mouse move or key press brings DPMS back).
hl.config({
  misc = {
    mouse_move_enables_dpms = true,
    key_press_enables_dpms = true,
    -- Animate mouse-drag window resizes. Keyboard resize (resizeactive,
    -- SUPER+ALT+HJKL) is dispatcher-driven and Hyprland never animates
    -- those; only layout-driven geometry (e.g. scrolling colresize) animates.
    animate_manual_resizes = true,
  },
})

-- Special-workspace reveal (SUPER+M emacs etc.): vertical slide on the
-- Garuda md3_decel curve — distinct from the plain workspace slide below.
hl.curve("md3_decel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "md3_decel", style = "slidevert" })
-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- wlogout power menu: blur the desktop behind it (same rule as the official
-- Garuda dotfiles; the layer's namespace is "logout_dialog").
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })
-- Fade the menu in/out (the layer rule's animation name maps to the
-- built-in layers fade).
hl.layer_rule({ match = { namespace = "logout_dialog" }, animation = "fade" })
-- Blur behind the top bar so its transparent mode (double-click toggle) frosts
-- the desktop instead of going fully clear.
hl.layer_rule({ match = { namespace = "omarchy-bar" }, blur = true })
-- Omarchy disables workspace-switch animations by default; re-enable with a
-- horizontal slide (curves are defined in the Omarchy defaults).
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "easeOutQuint", style = "slide" })

-- Blur params from the official dotfiles. ignore_opacity stays true (the
-- per-pixel-alpha experiment did not remove the dock's corner rectangle and
-- dulled the frost on the bar/menus — reverted at user request).
hl.config({
  decoration = {
    blur = {
      enabled            = true,
      xray               = false,
      size               = 5,
      passes             = 3,
      ignore_opacity     = true,
      new_optimizations  = true,
      noise              = 0.02,
      contrast           = 1.1,
      brightness         = 1.1,
    },
  },
})


-- App dock: slide in/out from its screen edge (bottom) like the quickshell
-- bar, instead of the global layer fade. No blur: the dock style.css runs
-- 0.80 opacity which looks better crisp (user preference, 2026-08-31).
hl.layer_rule({ match = { namespace = "nwg-dock" }, blur = false, animation = "slide" })


-- Standalone app-grid launcher (.config/qs-applauncher): blurred backdrop,
-- rofi-style. The omarchy system menu is deliberately left unblurred.
hl.layer_rule({ match = { namespace = "qs-applauncher" }, blur = true, no_anim = true })
