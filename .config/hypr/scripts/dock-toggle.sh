#!/usr/bin/env bash
# dock-toggle.sh - show/hide the nwg-dock-hyprland app dock.
# Triggered by 3-finger swipe up (touchscreen + touchpad, see bindings.lua).
# Ported from the Garuda dotfiles dock-toggle-hyprland: the waybar half is
# Garuda-only, the launcher is omarchy-menu (no rofi on Omarchy), and the
# Garuda-specific -g window-class groups were dropped.
if pgrep -f nwg-dock-hyprland >/dev/null; then
    pkill -f nwg-dock-hyprland
else
    nwg-dock-hyprland -i 40 -w 5 -mb 10 -ml 10 -mr 10 \
        -c "omarchy-menu toggle apps" >/dev/null 2>&1 &
fi
