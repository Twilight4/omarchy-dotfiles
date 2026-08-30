-- Change the default Omarchy look'n'feel.

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
-- noanim: skip the layersIn fade so the menu appears instantly.
hl.layer_rule({ match = { namespace = "logout_dialog" }, no_anim = true })
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

-- Snappier layer pop-ins (dock slide included; per-layer styles come from
-- the layer rules below, only speed/bezier are global).
hl.animation({ leaf = "layersIn", enabled = true, speed = 8, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 8, bezier = "linear", style = "fade" })

-- App dock: slide in/out from its screen edge (bottom) like the quickshell
-- bar, instead of the global layer fade.
hl.layer_rule({ match = { namespace = "nwg-dock" }, blur = true, animation = "slide" })

-- Rofi: blurred like the dock, but instant (no fade wait).
hl.layer_rule({ match = { namespace = "rofi" }, blur = true, no_anim = true })
