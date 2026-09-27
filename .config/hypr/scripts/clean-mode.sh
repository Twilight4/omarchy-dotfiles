#!/usr/bin/env bash
# Clean mode: blank the panel AND disable the touchscreen together (4-finger
# swipe left on the touchscreen/touchpad, or SUPER+SHIFT+F10). With dpms off,
# a touch would instantly re-wake the panel (touch rides Hyprland's unified
# mouse-move wake path), so both must go together. State = omarchy's own
# touchscreen toggle file (toggles/hypr/touchscreen-disabled-name), so the
# OSD toggle, menu rows, and this script never disagree. While clean mode is
# on, keyboard presses still wake the panel; re-run this to bring touch back.
set -euo pipefail

name_file=$HOME/.local/state/omarchy/toggles/hypr/touchscreen-disabled-name

if [[ -f $name_file ]]; then
  omarchy toggle touchscreen on
  hyprctl dispatch 'hl.dsp.dpms({action="enable"})' >/dev/null
  omarchy-notification-send -g 󰐤 "Clean mode off" "Panel + touchscreen on" || true
else
  omarchy toggle touchscreen off
  hyprctl dispatch 'hl.dsp.dpms({action="disable"})' >/dev/null
  omarchy-notification-send -g 󰆑 "Clean mode on" "Panel + touchscreen off" || true
fi
