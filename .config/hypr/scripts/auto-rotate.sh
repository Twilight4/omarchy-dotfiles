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
# Hyprland transforms are clockwise ints: 0 normal, 1 90, 2 180, 3 270.
# If rotation feels mirrored on your device, swap the left-up/right-up values.
#
# NOTE: `hyprctl output ... transform` does not exist on the new (Lua) config
# parser and `hyprctl keyword monitor` is rejected by it — the only runtime
# path is `hyprctl eval 'hl.monitor({...})'`. Scale is re-applied from the
# live state so this doesn't stomp monitors.lua.
#
# hyprmoncfgd re-applies its saved profile on every monitor-state change
# (~5s poll), which reverts a bare eval within seconds. After rotating we
# therefore `hyprmoncfg save` the ACTIVE profile so the rotation becomes the
# daemon's canonical state. Skipped silently when hyprmoncfg isn't in use.
last_transform=-1
monitor-sensor 2>/dev/null | while read -r line; do
    [[ -f $LOCK ]] && continue
    case $line in
        *"normal"*)    transform=0 ;;
        *"bottom-up"*) transform=2 ;;
        *"left-up"*)   transform=1 ;;
        *"right-up"*)  transform=3 ;;
        *) continue ;;
    esac
    [[ $transform == "$last_transform" ]] && continue
    scale=$(hyprctl monitors -j 2>/dev/null \
        | jq -r --arg n "$output_name" \
            '.[] | select(.name == $n) | .scale')
    [[ -n $scale ]] || continue
    hyprctl eval "hl.monitor({output = \"$output_name\", mode = \"preferred\", position = \"auto\", scale = $scale, transform = $transform})" &>/dev/null \
        || continue
    last_transform=$transform
    profile=$(hyprmoncfg status 2>/dev/null | sed -n 's/^Active profile: //p')
    [[ -n $profile && $profile != "none" ]] \
        && hyprmoncfg save "$profile" &>/dev/null
done
