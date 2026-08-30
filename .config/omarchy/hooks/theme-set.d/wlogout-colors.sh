#!/bin/bash
# Regenerate wlogout's GTK colors from the new theme's colors.toml.
# Thin wrapper so the tracked generator in ~/.config/wlogout stays the
# single source of truth (omarchy-hook-install copies hooks, which would
# otherwise drift).

exec "$HOME/.config/wlogout/generate-colors.sh"
