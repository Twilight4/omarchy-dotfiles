#!/usr/bin/env bash
# dock-toggle.sh - show/hide the nwg-dock-hyprland app dock.
# Triggered by 3-finger swipe up (touchscreen + touchpad, see bindings.lua).
# Ported from the Garuda dotfiles dock-toggle-hyprland: the waybar half is
# Garuda-only and the Garuda -g window-class groups were dropped. The
# launcher button opens rofi (Garuda config, configs/config.rasi).
if pgrep -f nwg-dock-hyprland >/dev/null; then
    pkill -f nwg-dock-hyprland
else
    nwg-dock-hyprland -i 30 -w 5 -mb 10 -ml 10 -mr 10 \
        -c "rofi -show drun -config ~/.config/rofi/configs/config.rasi" >/dev/null 2>&1 &
fi
