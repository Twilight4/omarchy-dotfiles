#!/usr/bin/env bash
# dock-toggle.sh - show/hide the nwg-dock-hyprland app dock.
# Triggered by 3-finger swipe up (touchscreen + touchpad, see bindings.lua).
# Ported from the Garuda dotfiles dock-toggle-hyprland: the waybar half is
# Garuda-only and the Garuda -g window-class groups were dropped. The
# launcher button opens rofi (Garuda config, configs/config.rasi).
if pgrep -f nwg-dock-hyprland >/dev/null; then
    pkill -f nwg-dock-hyprland
else
    # GDK_SCALE=2: GTK3 renders a 2x buffer for the same logical size —
    # without it the 1.6 monitor scale upscales a 1x surface (blurry icons).
    GDK_SCALE=2 nwg-dock-hyprland -i 30 -w 5 -mb 10 -ml 10 -mr 10 \
        -c "$HOME/.config/hypr/scripts/app-launcher.sh" >/dev/null 2>&1 &
fi
