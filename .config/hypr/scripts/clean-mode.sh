#!/usr/bin/env bash
# Clean mode: panel off + fullscreen opaque taeryn.cleanmode overlay that
# swallows ALL touch (apps get nothing). Entered AND exited by the SAME
# 4-finger DOWN swipe — hyprgrass sees raw touch regardless of what layer is
# up, so its bind (exempt from the clean-mode gating in bindings.lua) toggles
# this script both ways. Also SUPER+ALT+Y and the touchpad mirror in
# input.lua.
#
# While active, NO input re-lights the panel: both dpms wake options are
# switched off (restored to the looknfeel.lua values true/true on exit), so
# mouse moves and key presses leave the screen dark. Keyboard events still
# reach apps and binds — SUPER+ALT+Y keeps working as a keyboard exit.
set -euo pipefail

flag=$HOME/.local/state/omarchy/toggles/taeryn-clean-mode

if [[ -f $flag ]]; then
  rm -f "$flag"
  hyprctl dispatch 'hl.dsp.dpms({action="enable"})' >/dev/null
  hyprctl eval 'hl.config({ misc = { mouse_move_enables_dpms = true, key_press_enables_dpms = true } })' >/dev/null
  omarchy-notification-send -g 󰐤 "Clean mode off" "Panel + touch on" || true
else
  mkdir -p "$(dirname "$flag")"
  touch "$flag"
  hyprctl eval 'hl.config({ misc = { mouse_move_enables_dpms = false, key_press_enables_dpms = false } })' >/dev/null
  hyprctl dispatch 'hl.dsp.dpms({action="disable"})' >/dev/null
fi
