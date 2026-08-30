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
# rewrite the touch panel's transform in the profile that OWNS the panel and
# let `hyprmoncfg apply` make the change — daemon and live state stay in
# agreement, nothing ever reverts. Falls back to a bare eval when hyprmoncfg
# isn't managing this setup.
HYPRMONCFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hyprmoncfg"

set_profile_transform() {
    # $1 = transform int. Returns 1 when hyprmoncfg isn't usable.
    #
    # The profile is picked by OUTPUT IDENTITY (the file whose outputs[]
    # contains the touch panel), NOT by `hyprmoncfg status`'s "Active
    # profile": that name is live-state-dependent and reports a virtual
    # "custom layout" (which has no file) whenever live state drifts from
    # every saved profile — e.g. right after an external eval.
    local transform=$1 f file name tmp
    command -v hyprmoncfg &>/dev/null || return 1
    file=""
    for f in "$HYPRMONCFG_DIR"/profiles/*.json; do
        [[ -e $f ]] || continue
        jq -e --arg d "$TOUCH_OUTPUT_DESC" \
            'any(.outputs[]; (.description // "") | startswith($d))' "$f" &>/dev/null || continue
        file=$f
        break
    done
    [[ -n $file ]] || return 1
    name=$(jq -r '.name' "$file")
    tmp=$(mktemp) || return 1
    jq --arg d "$TOUCH_OUTPUT_DESC" --argjson t "$transform" \
        '.outputs |= map(if ((.description // "") | startswith($d))
                         then .transform = $t else . end)' \
        "$file" > "$tmp" && mv "$tmp" "$file" || { rm -f "$tmp"; return 1; }
    # --confirm-timeout 0: no interactive revert prompt (daemon context).
    hyprmoncfg apply "$name" --confirm-timeout 0 &>/dev/null
}

# Touch input has its own transform, independent of the monitor's — rotate it
# with the panel or touch lands offset/mirrored. `output` pins the touch
# device to the panel so it never targets an external monitor.
set_touch_transform() {
    hyprctl eval "hl.config({ input = { touchdevice = { transform = $1, output = \"$output_name\" } } })" &>/dev/null
}

# Sync touch with the panel's current transform at startup — the loop below
# only reacts to accelerometer change events.
current_transform=$(hyprctl monitors -j 2>/dev/null \
    | jq -r --arg n "$output_name" '.[] | select(.name == $n) | (.transform // 0)')
set_touch_transform "${current_transform:-0}"

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
    set_touch_transform "$transform"
    last_transform=$transform
done
