#!/bin/bash
# Re-tint the nwg dock background from the new theme's colors.toml.
# Thin wrapper so the tracked generator in ~/.config/nwg-dock-hyprland
# stays the single source of truth (omarchy-hook-install copies hooks,
# which would otherwise drift).

exec "$HOME/.config/nwg-dock-hyprland/generate-colors.sh"
