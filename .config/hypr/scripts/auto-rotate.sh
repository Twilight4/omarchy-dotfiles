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
# Rotation goes THROUGH hyprmoncfg: hyprmoncfgd re-applies the active profile
# on every poll-detected monitor change, so a bare `hyprctl eval` gets
# reverted within seconds (and races a `save`-based workaround). Instead we
# rewrite the touch panel's transform in the ACTIVE profile and let
# `hyprmoncfg apply` make the change — daemon and live state stay in
# agreement, nothing ever reverts. Falls back to a bare eval when hyprmoncfg
# isn't managing this setup.
HYPRMONCFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hyprmoncfg"

set_profile_transform() {
    # $1 = transform int. Returns 1 when hyprmoncfg isn't usable.
    local transform=$1 active file tmp
    command -v hyprmoncfg &>/dev/null || return 1
    active=$(hyprmoncfg status 2>/dev/null | sed -n 's/^Active profile: //p')
    [[ -n $active && $active != none ]] || return 1
    # Profile files are slugged (custom layout -> custom-layout.json);
    # match on the JSON "name" field instead of guessing the slug.
    file=$(grep -lF "\"name\": \"$active\"" "$HYPRMONCFG_DIR"/profiles/*.json 2>/dev/null | head -1)
    [[ -n $file ]] || return 1
    tmp=$(mktemp) || return 1
    jq --arg d "$TOUCH_OUTPUT_DESC" --argjson t "$transform" \
        '.outputs |= map(if ((.description // "") | startswith($d))
                         then .transform = $t else . end)' \
        "$file" > "$tmp" && mv "$tmp" "$file" || { rm -f "$tmp"; return 1; }
    # --confirm-timeout 0: no interactive revert prompt (daemon context).
    hyprmoncfg apply "$active" --confirm-timeout 0 &>/dev/null
}

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
    if ! set_profile_transform "$transform"; then
        # No hyprmoncfg: bare eval path (`hyprctl output ... transform` does
        # not exist on the Lua parser; `keyword monitor` is rejected).
        scale=$(hyprctl monitors -j 2>/dev/null \
            | jq -r --arg n "$output_name" \
                '.[] | select(.name == $n) | .scale')
        [[ -n $scale ]] || continue
        hyprctl eval "hl.monitor({output = \"$output_name\", mode = \"preferred\", position = \"auto\", scale = $scale, transform = $transform})" &>/dev/null \
            || continue
    fi
    last_transform=$transform
done
