#!/usr/bin/env bash
# auto-rotate.sh - rotate the built-in touch panel from the accelerometer.
# Requires: iio-sensor-proxy (`monitor-sensor`), hyprctl, jq — exits silently
# when any of them (or the panel) is missing, so the autostart entry is safe
# on desktops / docked-only use.
#
# Usage:
#   auto-rotate.sh        foreground loop (autostarted from autostart.lua)
#   auto-rotate.sh lock   toggle the rotation lock (freeze current transform)

# Built-in 2-in-1 panel (hyprmoncfg-monitors.lua): Sharp LQ134N1JW53/54
# 1920x1200. Matched by description prefix so the name (eDP-1/XWayland-0...)
# can change between sessions.
TOUCH_OUTPUT_DESC="Sharp Corporation LQ134N1JW"
LOCK="${XDG_RUNTIME_DIR:-/tmp}/auto-rotate.lock"

if [[ $1 == "lock" ]]; then
    if [[ -f $LOCK ]]; then
        rm -f "$LOCK"
        echo "auto-rotate: unlocked"
    else
        touch "$LOCK"
        echo "auto-rotate: locked (transform frozen)"
    fi
    exit 0
fi

command -v monitor-sensor &>/dev/null || exit 0
command -v jq &>/dev/null || exit 0
command -v hyprctl &>/dev/null || exit 0

output_name=$(hyprctl monitors -j 2>/dev/null \
    | jq -r --arg d "$TOUCH_OUTPUT_DESC" \
        '.[] | select((.description // "") | startswith($d)) | .name' \
    | head -1)
[[ -n $output_name ]] || exit 0

# monitor-sensor streams "Accelerometer orientation changed: <orient>" lines.
# Mapping (hyprland transforms are clockwise): device left-edge-up -> screen
# content rotated 90 CW, etc.
monitor-sensor 2>/dev/null | while read -r line; do
    [[ -f $LOCK ]] && continue
    case $line in
        *"normal"*)    transform=normal ;;
        *"bottom-up"*) transform=180 ;;
        *"left-up"*)   transform=90 ;;
        *"right-up"*)  transform=270 ;;
        *) continue ;;
    esac
    hyprctl output "$output_name" transform "$transform" &>/dev/null
done
