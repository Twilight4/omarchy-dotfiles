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
-- on-screen keyboard. Sensitivity 4.0 is hyprgrass's own tablet recommendation.
-- Guarded like the official gestures.lua: hyprpm loads plugins AFTER the
-- config parses, so an unguarded plugin.* config errors at startup/reload
-- ("unknown option plugin:hyprgrass:sensitivity") whenever the plugin isn't
-- loaded yet.
if hl.plugin.hyprgrass ~= nil then
    hl.config({
      plugin = {
        hyprgrass = {
          sensitivity = 4.0,
        },
      },
    })
    hl.plugin.hyprgrass.bind({
      pattern = { kind = "edge", origin = "down", direction = "up" },
      action = hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/osk-toggle.sh"),
    })
end
